#!/bin/sh
# https://github.com/alexwbaule/telegramopenwrt/blob/master/plugins/wll_list
for wifi in wlan0 wlan1
do
	if [ "${wifi}" == "wlan0" ]; then
		echo -en "-----------------*${wifi} - 2.4 Ghz*-----------------------\n"
	else
		echo -en "-----------------*${wifi} - 5 Ghz*-------------------------\n"
	fi
	macaddr=$(iw dev ${wifi} station dump | grep Station | grep -oE "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}" | awk '{printf $0 " "}')
	for lease in ${macaddr}
	do
		line=$(cat /tmp/dhcp.leases | grep ${lease})
		if [ $? == 0 ]; then
			echo "${line}" | awk '{gsub( "*","\\*" ); gsub( "_","\\_" ); printf "Device: " $4 "\nIP: " $3 "\nMac: " toupper($2) "\nState: ";system("./functions/get_ping.sh "$4" 1");printf "\n"}'
		else
			cat /proc/net/arp | grep ${lease} | awk '{gsub( "_","\\_" ); printf "IP: " $1 "\nMac: " toupper($4) "\nState: ";system("./functions/get_ping.sh "$1" 1");printf "\n"}'
		fi
		./functions/get_mac.sh "${lease}"
		echo -en "\n"
	done
	#echo -en "-----------------------------------------------------------\n"
done