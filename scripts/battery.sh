#!/bin/bash

# Install tlp and enable the service:
# sudo systemctl enable tlp.service

# Check for the correct number of arguments and root privileges
if [[ $# -ne 1 ]] || [[ "$EUID" -ne 0 ]]; then
    echo "Usage: $0 <reset|balanced|hot|status>"
    echo "Run as root."
    exit 1
fi

# Main logic based on the command
case "$1" in
    reset)
        echo "Setting default values"
        tlp setcharge 0 100 BAT0
        tlp setcharge 0 100 BAT1
        ;;
    balanced)
        echo "Setting battery-friendly values"
        tlp setcharge 38 45 BAT0
        tlp setcharge 38 55 BAT1
        ;;
    hot)
        echo "Charging external battery some extra"
        tlp setcharge 38 45 BAT0
        tlp setcharge 71 73 BAT1
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

