#!/bin/bash
PING_IP="<PING_TEST_IP>"

declare -a VPN_INTERFACES=(
	"IF_NAME_1"
	"IF_NAME_2"
)


function change_interface() {
	prev_interface=$(<current_interface.txt)

	# Start interface
	next_interface=${VPN_INTERFACES[RANDOM%${#VPN_INTERFACES[@]}]}
	while [ $next_interface == $prev_interface ]; do
		echo "next_interface is same as old, ($prev_interface, $next_interface)"
		next_interface=${VPN_INTERFACES[RANDOM%${#VPN_INTERFACES[@]}]}
	done

	ifup $next_interface
	echo $next_interface>"current_interface.txt"

	# Stop current interface
	if [[ -z $current_interface ]]; then
		ifdown $prev_interface
	fi

	return 0
}

function test_vpn() {
	try=0
	while [[ $try -lt 3 ]]
	do
		if /bin/ping -w 10 -c 1 $PING_IP &>/dev/null; then
			echo Interface working
			return 0
		fi
		try=$((try+1))
	done
	echo Interface NOT working
	return 1
}

test_vpn
if [[ $? -ne 0 ]]; then
	echo Changing interface
	change_interface
fi
