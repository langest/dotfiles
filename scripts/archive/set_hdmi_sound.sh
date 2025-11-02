#!/bin/bash

if [[ $# -eq 2 ]]
then
	echo "Usage: $0 <on|off|status>"
	echo "Example: $0 on"
	exit 1
fi

STATUS="$1"
if [[ ! ($STATUS = "off" || $STATUS = "on" || $STATUS = "status") ]]
then
	echo "Requires parameter on, off or status"
	echo "Usage: $0 <on|off>"
	echo "Example: $0 on"
	exit 1
fi

if [[ $STATUS = "status" ]]
then
	if [[ -f ~/.asoundrc ]]
	then
		echo "HDMI sound ON"
	else
		echo "HDMI sound OFF"
	fi
	exit 0
fi

if [[ $STATUS = "off" ]]
then
	echo "rm ~/.asoundrc"
	rm ~/.asoundrc
	echo "Done"
	exit 0
fi

echo "cp ~/asoundrc.src .asoundrc"
cp ~/.asoundrc.src ~/.asoundrc
echo "Done"
exit 0
