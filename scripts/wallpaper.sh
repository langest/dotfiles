#!/bin/bash

if [[ $MONITOR_SETTINGS = "external" ]]; then
	# Oneliner that does the same thing

	# cat <(find $HOME/img/wps_portrait/ -type f -printf '"%p"\n' | sort -R | head -n1) <(find $HOME/img/wps/ -type f -printf '"%p"\n' | sort -R | head -n1) | xargs feh --bg-fill
	LANDSCAPE=`find $HOME/Pictures/wps/ -type f | sort -R | head -n1`

	PORTRAIT=`find $HOME/Pictures/wps_portrait/ -type f | sort -R | head -n1`

	feh --bg-fill "$LANDSCAPE" "$PORTRAIT"

	exit 0
fi

feh --randomize --recursive --bg-fill $HOME/Pictures/wps
