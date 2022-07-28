#!/bin/bash

if [[ $# -eq 2 ]]; then
	echo "Usage: $0 <reset|balanced|status>"
	echo "Example: $0 on"
	exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
	echo "Run as root"
	exit 1
fi


CMD="$1"
if [[ ! ($CMD = "reset" || $CMD = "balanced" || $CMD = "hot" || $CMD = "status") ]]; then
	echo "Requires parameter reset, balanced, hot or status"
	echo "Usage: $0 <reset|balanced|hot|status>"
	echo "hot: charges external battery more than balanced"
	echo "Example: $0 reset"
	exit 1
fi

if [[ $CMD = "reset" ]]; then
	echo "Setting default values"
	tpacpi-bat -s ST 1 0
	tpacpi-bat -s SP 1 0
	tpacpi-bat -s ST 2 0
	tpacpi-bat -s SP 2 0
fi

if [[ $CMD = "balanced" ]]; then
	echo "Setting battery friendly values"
	tpacpi-bat -s ST 1 38
	tpacpi-bat -s SP 1 45
	tpacpi-bat -s ST 2 38
	tpacpi-bat -s SP 2 55
fi

if [[ $CMD = "hot" ]]; then
	echo "Charging external battery som extra"
	tpacpi-bat -s ST 1 38
	tpacpi-bat -s SP 1 45
	tpacpi-bat -s ST 2 71
	tpacpi-bat -s SP 2 73
fi

echo "Battery 1 limits"
tpacpi-bat -g ST 1
tpacpi-bat -g SP 1
echo "Battery 2 limits"
tpacpi-bat -g ST 2
tpacpi-bat -g SP 2
exit 0
