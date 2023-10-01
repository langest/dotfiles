#!/bin/bash

HDMI1_position="0x0"
HDMI2_position="-1200x-362"

if [[ $MONITOR_SETTINGS = "external" ]]; then
	xrandr --output eDP1 --off
	sleep 1.4
	xrandr --output HDMI1 --mode 1920x1200 --pos $HDMI1_position --primary
	sleep 0.3
	xrandr --output HDMI2 --mode 1920x1200 --rotate left --pos $HDMI2_position
else
	xrandr --output eDP1 --auto --primary
	sleep 0.1
	xrandr --output HDMI1 --off
	sleep 0.1
	xrandr --output HDMI2 --off
fi

bash `dirname "$0"`/wallpaper.sh

# Make sure to have proper keyboard layout
setxkbmap -option ctrl:nocaps

