#!/usr/bin/env bash

readonly brightnessDirectory="/sys/class/backlight/intel_backlight"

# Phosphor style icons
readonly moon=
readonly twilight=
readonly lowSun=
readonly highSun=

getBrightness() {
    cat "$brightnessDirectory/brightness"
}

getMaxBrightness() {
    cat "$brightnessDirectory/max_brightness"
}

getBrightnessPercentage() {
    current=$(getBrightness)
    maximum=$(getMaxBrightness)
    echo $(( ($current * 100) / $maximum ))
}

getIcon() {
    brightness=$1
    if (( brightness >= 50 )); then
        echo $highSun
    elif (( brightness >= 20 )); then
        echo $lowSun
    elif (( brightness > 0 )); then
        echo $twilight
    else
        echo $moon
    fi
}

outputJSON() {
    brightnessPercentage=$(getBrightnessPercentage)
    icon=$(getIcon $brightnessPercentage)
    echo "{\"value\": $brightnessPercentage, \"icon\": \"$icon\"}"
}

echo $(outputJSON)
inotifywait -q -e modify -m "$brightnessDirectory/brightness" | while read line; do
    echo $(outputJSON)
done