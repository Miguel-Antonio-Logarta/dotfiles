#!/usr/bin/python3

from typing import Dict, List
from i3ipc import Connection, Event, ModeEvent
import json

WORKSPACE_ACTIVE = "ACTIVE"
WORKSPACE_OCCUPIED = "OCCUPIED"
WORKSPACE_URGENT = "URGENT"
WORKSPACE_EMPTY = "EMPTY"
NUM_WORKSPACES = 9
MODE_DEFAULT = "DEFAULT"
MODE_RESIZE = "RESIZE"

# NOTE: With this script, the fans are starting to run louder. Performance issue?

def output_eww_data(eww_data):
    output_json = json.dumps(eww_data)
    print(output_json, flush=True) # Flushing is very important. Eww will not update if you do not flush. For the love of God whyyyyyy


def create_initial_workspaces_data(total_workspaces) -> List[Dict[str, any]]:
    workspaces_data = []
    for workspace_num in range(1, total_workspaces + 1):
        workspaces_data.append({
            "workspace_number": workspace_num,
            "status": WORKSPACE_EMPTY,
            "i3_command": f"i3-msg workspace number {workspace_num}",
            "class": "workspace-empty"
        })
    return workspaces_data


def get_eww_workspaces(i3: Connection) -> List[Dict[str, any]]:
    new_workspaces = create_initial_workspaces_data(NUM_WORKSPACES)
    workspaces_reply = i3.get_workspaces()

    for workspace in workspaces_reply:
        ipc_data = workspace.ipc_data
        workspace_index = ipc_data['num'] - 1
        if ipc_data['focused']:
            new_workspaces[workspace_index].update({
                "status": WORKSPACE_ACTIVE,
                "class": "workspace-active"
            })
        elif ipc_data['urgent']:
            new_workspaces[workspace_index].update({
                "status": WORKSPACE_URGENT,
                "class": "workspace-urgent"
            })
        else:
            new_workspaces[workspace_index].update({
                "status": WORKSPACE_OCCUPIED,
                "class": "workspace-occupied"
            })
    
    return new_workspaces


def handle_window_focus(i3: Connection, e: ModeEvent, eww_data) -> None:
    eww_data['workspaces'] = get_eww_workspaces(i3)
    output_eww_data(eww_data)


def handle_mode(i3: Connection, e: ModeEvent, eww_data) -> None:
    ipc_data = e.ipc_data
     
    if ipc_data['change'] == 'resize':
        eww_data['mode'] = MODE_RESIZE
    else:
        eww_data['mode'] = MODE_DEFAULT

    output_eww_data(eww_data)


if __name__ == "__main__":
    i3 = Connection()

    eww_data = {
        "mode": MODE_DEFAULT,
        "workspaces": get_eww_workspaces(i3)
    }

    output_eww_data(eww_data)

    i3.on(Event.WORKSPACE_FOCUS, lambda i3, e: handle_window_focus(i3, e, eww_data))
    i3.on(Event.MODE, lambda i3, e: handle_mode(i3, e, eww_data))
    i3.main()
