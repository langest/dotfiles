#!/bin/bash

if [[ $MONITOR_SETTINGS = "external" ]]; then
	# Oneliner that does the same thing

	# cat <(find $HOME/img/wps_portrait/ -type f -printf '"%p"\n' | sort -R | head -n1) <(find $HOME/img/wps/ -type f -printf '"%p"\n' | sort -R | head -n1) | xargs feh --bg-fill
	LANDSCAPE=`find $HOME/img/wps/ -type f | sort -R | head -n1`

	PORTRAIT=`find $HOME/img/wps_portrait/ -type f | sort -R | head -n1`

	feh --bg-fill "$PORTRAIT" "$LANDSCAPE"

	exit 0
fi

feh --randomize --recursive --bg-fill $HOME/img/wps