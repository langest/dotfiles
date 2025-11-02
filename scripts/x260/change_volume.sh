#!/bin/bash

# Get the volume using amixer and try different patterns
get_volume() {
    # Try different patterns that might appear in amixer output
    volume=$(amixer get Master | grep -E '\[([0-9]+)%\]' | head -n 1 | sed -r 's/.*\[([0-9]+)%\].*/\1/')
    echo "${volume:-0}"  # Return 0 if volume is empty
}

current_volume=$(get_volume)

case "$1" in
    "increase")
        if [ "$current_volume" -lt 95 ]; then
            amixer -q set Master 5%+
        else
            amixer -q set Master 100%
        fi
        ;;
    "decrease")
        if [ "$current_volume" -gt 5 ]; then
            amixer -q set Master 5%-
        else
            amixer -q set Master 0%
        fi
        ;;
    *)
        echo "Usage: $0 {increase|decrease}"
        exit 1
        ;;
esac
