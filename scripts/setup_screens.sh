#!/bin/bash

#feh --randomize --recursive --bg-fill /home/langest/img/wps
#/home/langest/.fehbg

if [[ $MONITOR_SETTINGS = "external" ]]; then
	xrandr --output eDP1 --off
	sleep 1.3
	xrandr --output HDMI2 --mode 1920x1200
	xrandr --output HDMI1 --left-of HDMI2 --mode 1920x1200 --rotate left
fi

bash `dirname "$0"`/wallpaper.sh
