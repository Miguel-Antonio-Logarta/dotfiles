#!/usr/bin/env bash

# Icons
readonly batteryLow=""
readonly batteryMedium=""
readonly batteryHigh=""
readonly batteryFull=""
readonly batteryCharging=""

pollingInterval=1             # Measured in seconds
chargeStatus=""
percentage=0
remainingTime=""
currentIcon=""

getBatteryInfo() {
    acpi -b
}

formatBatteryInfo() {
    IFS=',' read -r chargeStatus percentage remainingTime <<< "$(getBatteryInfo)"
    
    if [[ "$chargeStatus" == *"Full"* ]]; then
        chargeStatus="full"
    elif [[ "$chargeStatus" == *"Charging"* ]]; then
        chargeStatus="charging"
    else 
        chargeStatus="discharging"
    fi

    percentage=$(echo $percentage | tr -d '%')

    if [[ "$remainingTime" != *"unavailable"* ]]; then
        newRemainingTime=$(echo "$remainingTime" | awk '{print $1}')
        remainingTime="$newRemainingTime"
    else 
        remainingTime="unavailable"
    fi
}

getIcon() {
    if [[ "$chargeStatus" == "charging" ]]; then
        currentIcon="$batteryCharging"
    elif (( percentage >= 90 )); then
        currentIcon="$batteryFull"
    elif (( percentage >= 60 )); then
        currentIcon="$batteryHigh"
    elif (( percentage >= 30 )); then
        currentIcon="$batteryMedium"
    elif ((percentage >= 0)); then
        currentIcon="$batteryLow"
    fi
}

# {"status": "charging", "icon": "", "value": 40}
# {"status": "discharging", "icon": "", "value": 40}
# {"status": "full", "icon": "", "value": 40}
outputJSON() {
    formatBatteryInfo
    getIcon
    echo "{\"status\": \"$chargeStatus\", \"icon\": \"$currentIcon\", \"value\": $percentage}"
    # echo $(formatBatteryInfo)
}

while true; do
    outputJSON
    sleep $pollingInterval
done
