#!/usr/bin/env bash

# Subscribe to the i3 IPC and listen for mode changes. 
# i3 IPC sends messages with JSON
i3-msg -t subscribe -m '["mode"]' | while read line; do
    # Get the line | Get value of the 'change' key | trim the quotes
    echo $line | jq '.change' | tr -d \"
done