#!/bin/bash
PING_IP="<PING_TEST_IP>"

declare -a VPN_INTERFACES=(
	"IF_NAME_1"
	"IF_NAME_2"
)

print_usage() {
	echo "This is a simple script that can test if the current connection"
	echo "is working and rotate to a different vpn interface is necessary."
	echo "This program will create or overwrite a file with the current interface used."
	echo "By default it will:"
	echo "  Rotate on a failed test."
	echo '  Use a file "/tmp/current_interface.txt" to track current interface.'
	echo ""
	echo "Usage: $0 [OPTION]"
	echo "Options:"
	echo "  --help   | -h Print this help message"
	echo "  --rotate | -r Force a vpn rotation without testing if it works"
	echo "Example: $0 --force"
}

if [[ $# -gt 1 || $1 == '--help' || $1 == '-h' ]]; then
	print_usage
	exit 1
fi

VALID_FLAGS=("--help", "-h", "--rotate", "-r")
FLAG="$1"
if [[ ! ${VALID_FLAGS[*]} =~ $FLAG ]]; then
	echo "Invalid flag: ${FLAG}"
	print_usage
	exit 1
fi

function change_interface() {
	prev_interface=$(<current_interface.txt)

	# Start interface
	next_interface=${VPN_INTERFACES[RANDOM%${#VPN_INTERFACES[@]}]}
	while [ $next_interface == $prev_interface ]; do
		echo "next_interface is same as old, ($prev_interface, $next_interface)"
		next_interface=${VPN_INTERFACES[RANDOM%${#VPN_INTERFACES[@]}]}
	done

	ifup $next_interface
	echo $next_interface>"/tmp/current_interface.txt"

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

$? = 0
if [[  $1 != '--rotate' && $1 != '-r' ]]; then
	test_vpn
fi
if [[ $? -ne 0 ]]; then
	echo Changing interface
	change_interface
fi
