#!/bin/bash

HDMI1_position="1200x361"
HDMI2_position="0x0"

if [[ $MONITOR_SETTINGS = "external" ]]; then
	xrandr --output eDP1 --off
	sleep 1.3
	xrandr --output HDMI1 --mode 1920x1200 --pos $HDMI1_position
	xrandr --output HDMI2 --mode 1920x1200 --rotate left --pos $HDMI2_position
else
	xrandr --output eDP1 --auto
	sleep 0.1
	xrandr --output HDMI1 --off
	sleep 0.1
	xrandr --output HDMI2 --off
fi

bash `dirname "$0"`/wallpaper.sh

