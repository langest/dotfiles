#!/bin/bash

# Set wallpaper based on the MONITOR_SETTINGS variable

if [[ $MONITOR_SETTINGS = "external" ]]; then
	# Randomly select one wallpaper for landscape and one for portrait
	LANDSCAPE=$(find $HOME/Pictures/wps/ -type f | sort -R | head -n1)
	PORTRAIT=$(find $HOME/Pictures/wps_portrait/ -type f | sort -R | head -n1)

	# Set the landscape and portrait wallpapers for external monitors
	feh --bg-fill "$LANDSCAPE" "$PORTRAIT"

	exit 0
elif [[ $MONITOR_SETTINGS = "all" ]]; then
	# Select one wallpaper each for eDP1, HDMI1 (landscape), and HDMI2 (portrait)
	EDP_WALLPAPER=$(find $HOME/Pictures/wps/ -type f | sort -R | head -n1)
	LANDSCAPE=$(find $HOME/Pictures/wps/ -type f | sort -R | head -n1)
	PORTRAIT=$(find $HOME/Pictures/wps_portrait/ -type f | sort -R | head -n1)

	# Set wallpapers for eDP1, HDMI1, and HDMI2
	feh --bg-fill "$EDP_WALLPAPER" "$LANDSCAPE" "$PORTRAIT"

	exit 0
fi

# Default behavior: randomize wallpapers from the wps folder
feh --randomize --recursive --bg-fill $HOME/Pictures/wps

