#!/bin/sh
# <https://github.com/alexwbaule/telegramopenwrt/blob/master/plugins/swports_list>

IFS=$'\n'
PORTS=$(swconfig dev switch0 show | grep link | grep -oE "port:[[:digit:]][[:space:]]link:(up|down)([[:space:]]speed:[[:digit:]]+|$)")
for port in $PORTS
do
	id=$(echo $port | grep -oE "port:[[:digit:]]" | cut -d ':' -f 2)
	if [ "$id" == "0" ]
		then
		echo "CPU"
	elif [ "$id" == "1" ]
		then
		echo "WAN"
	elif [ "$id" == "2" ]
		then
		echo "LAN 1"
	elif [ "$id" == "3" ]
		then
		echo "LAN 2"
	elif [ "$id" == "4" ]
		then
		echo "LAN 3"
	elif [ "$id" == "5" ]
		then
		echo "LAN 4"
	elif [ "$id" == "6" ]
		then
		echo "EMPTY"
	fi
	echo -en "${port// /\n}\n\n"
done