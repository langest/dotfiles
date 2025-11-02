#!/bin/bash
set -e
#set -x

HDMI1_position="1200x355"
HDMI2_position="0x0"
eDP1_position="3120x475"

if [ "$MONITOR_SETTINGS" = "external" ]; then
	xrandr --output eDP1 --off
	xrandr --output HDMI2 --mode 1920x1200 --rotate left --pos $HDMI2_position
	xrandr --output HDMI1 --mode 1920x1200 --pos $HDMI1_position --primary
elif [ "$MONITOR_SETTINGS" = "all" ]; then
	xrandr --output HDMI2 --mode 1920x1200 --rotate left --pos $HDMI2_position
	xrandr --output eDP1 --mode 1920x1080 --pos $eDP1_position
	xrandr --output HDMI1 --mode 1920x1200 --pos $HDMI1_position --primary
else
	xrandr --output HDMI1 --off
	xrandr --output HDMI2 --off
	xrandr --output eDP1 --auto --primary
fi

xrandr --dpi 96

bash `dirname "$0"`/wallpaper.sh

# Make sure to have proper keyboard layout
setxkbmap -option ctrl:nocaps

