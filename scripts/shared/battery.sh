#!/bin/bash

# Install tlp and enable the service:
# sudo systemctl enable tlp.service

# Check for the correct number of arguments and root privileges
if [[ $# -ne 1 ]] || [[ "$EUID" -ne 0 ]]; then
    echo "Usage: $0 <reset|balanced|hot|status>"
    echo "Run as root."
    exit 1
fi

# Function to safely set charge if battery exists
set_battery_charge() {
    local start=$1
    local stop=$2
    local bat=$3

    if [ -d "/sys/class/power_supply/$bat" ]; then
        echo "Configuring $bat: Start $start%, Stop $stop%"
        tlp setcharge $start $stop $bat
    else
        echo "Battery $bat not detected, skipping."
    fi
}

# Main logic based on the command
case "$1" in
    reset)
        echo "Setting default values (100% both)"
        set_battery_charge 0 100 BAT0
        set_battery_charge 0 100 BAT1
        ;;
    balanced)
        echo "Setting battery-friendly values"
        set_battery_charge 38 45 BAT0
        set_battery_charge 38 55 BAT1
        ;;
    hot)
        echo "Charging external battery some extra"
        set_battery_charge 38 45 BAT0
        set_battery_charge 71 73 BAT1
        ;;
    status)
        tlp-stat -b
        exit 0
        ;;
    *)
        echo "Invalid command."
        echo "Requires parameter reset, balanced, hot, or status"
        exit 1
        ;;
esac

# Apply TLP settings, unless the command is 'status'
if [[ "$1" != "status" ]]; then
    echo "Applying changes..."
    tlp start
fi

exit 0

