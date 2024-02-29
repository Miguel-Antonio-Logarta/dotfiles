#!/usr/bin/env bash

find_workspace_status() {
    # wmctrl -d | awk '{ print $1 " " $2 " " $9 }'
    # $1 is the workspace name
    # Outputs either "*", "-" or ""
    wmctrl -d | awk '{ print $2 " " $9 }' | grep $1 | awk '{ print $1 }'
}

get_literal() {
    # Gives a yuck literal depending on if the workspace is active, inactive, or unoccupied
    # $1 is the workspace name
    status=$(find_workspace_status "$1")
    if [ "$status" == "*" ]; then
        echo "(button :class \"active\"  :onclick \"i3-msg workspace number $1\" $1)"
    elif [ "$status" == "-" ]; then
        echo "(button :class \"inactive\"  :onclick \"i3-msg workspace number $1\" $1)"
    else
        echo "(button :class \"unoccupied\"  :onclick \"i3-msg workspace number $1\" $1)"
    fi 
}

get_button_list() {
    parentContainerPrefix="(box :class \"workspaces\" :vexpand \"true\" :orientation \"h\" :space-evenly true :halign \"start\" :spacing 16"  
    ws1=$(get_literal "1")
    ws2=$(get_literal "2")
    ws3=$(get_literal "3")
    ws4=$(get_literal "4")
    ws5=$(get_literal "5")
    ws6=$(get_literal "6")
    ws7=$(get_literal "7")
    ws8=$(get_literal "8")
    ws9=$(get_literal "9")
    echo "$parentContainerPrefix $ws1$ws2$ws3$ws4$ws5$ws6$ws7$ws8$ws9)"
    # echo "--------------------"
    # echo "$parentContainerPrefix $ws1$ws2$ws3$ws4$ws5$ws6$ws7$ws8$ws9)" >> ~/.config/eww/scripts/output/workspaces
}

# xprop spies on the root window (current window) forever
# List of window properties: https://specifications.freedesktop.org/wm-spec/1.3/ar01s03.html
# xprop -spy -root _NET_CURRENT_DESKTOP | while read -r; do
# echo "" > ~/.config/eww/scripts/output/workspaces
xprop -spy -root _NET_CLIENT_LIST | while read -r; do
    echo "$(get_button_list)"
done