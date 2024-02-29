#!/usr/bin/env bash

# Phosphor style icons
readonly volumeMute=""
readonly volumeLow=""
readonly volumeMedium=""
readonly volumeHigh=""

# Gets volume level using wpctl and outputs it in a range between 0-100
getPercentage() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
}

# Function that selects the right icon based on volume and muted state
getIcon() {
    mutedState=$1
    if [[ "$mutedState" == true ]]; then
        echo $volumeMute
    elif ((percentage >= 50)); then
        echo $volumeHigh
    elif ((percentage > 0)); then
        echo $volumeMedium
    else
        echo $volumeLow
    fi
}

# Uses wpctl and wildcards to find if the volume is muted
getMutedState() {
    volumeState=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

    # Wilcard match. If MUTED is in the string, then it is muted
    if [[ "$volumeState" == *"MUTED"* ]]; then
        echo true
    else
        echo false
    fi
}

# Outputs a JSON response that  looks like this: 
# {"icon": "", "value": 30, "muted": true}
getJSON() {
    percentage=$(getPercentage)
    muted=$(getMutedState)
    icon=$(getIcon $muted)
    echo "{\"icon\": \"$icon\", \"value\": $percentage, \"muted\": $muted}"
}

echo $(getJSON)
pactl subscribe | grep --line-buffered "Event 'change' on sink" | while read -r event; do
    echo $(getJSON)
done

