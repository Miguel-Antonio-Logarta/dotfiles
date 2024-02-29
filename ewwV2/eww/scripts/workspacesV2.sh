# For workspaces 1 to 9
# If workspace is active print active literal
# Elif workspace is present print occupied workspace literal
# Else print empty workspace literal


get_button_list() {
    
}

# When this script is run, listen for window updates
xprop -spy -root _NET_CLIENT_LIST | while read -r; do
    echo "$(get_button_list)"
done