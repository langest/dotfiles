#!/bin/bash

# Set wallpaper based on the MONITOR_SETTINGS variable

if [ "$MONITOR_SETTINGS" = "external" ]; then
	# Select one wallpaper each for eDP1, HDMI1 (landscape), and HDMI2 (portrait)
	PORTRAIT=$(find $HOME/Pictures/wps_portrait/ -type f | sort -R | head -n1)
	LANDSCAPE_0=$(find $HOME/Pictures/wps/ -type f | sort -R | head -n1)

	feh --bg-fill "$LANDSCAPE_0" "$PORTRAIT"
	exit 0
fi
if [ "$MONITOR_SETTINGS" = "all" ]; then
	# Select one wallpaper each for eDP1, HDMI1 (landscape), and HDMI2 (portrait)
	PORTRAIT=$(find $HOME/Pictures/wps_portrait/ -type f | sort -R | head -n1)
	LANDSCAPE_0=$(find $HOME/Pictures/wps/ -type f | sort -R | head -n1)
	LANDSCAPE_1=$(find $HOME/Pictures/wps/ -type f | sort -R | head -n1)

	feh --bg-fill "$LANDSCAPE_0" "$LANDSCAPE_1" "$PORTRAIT"
	exit 0
fi

# Default behavior: randomize wallpapers from the wps folder
feh --randomize --recursive --bg-fill $HOME/Pictures/wps

