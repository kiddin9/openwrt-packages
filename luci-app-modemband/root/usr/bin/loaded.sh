#!/bin/sh

#
# Copyright 2022-2023 Rafał Wabik (IceG) - From eko.one.pl forum
#
# MIT License
#

RES="/usr/share/modemband"

# modem type
getmodem() {

MDM=$(uci -q get modemband.@modemband[0].modemid)

if [ "${MDM}" == "" ]; then

		_DEVS=$(awk '/Vendor=/{gsub(/.*Vendor=| ProdID=| Rev.*/,"");print}' /sys/kernel/debug/usb/devices | sort -u)
			for _DEV in $_DEVS; do
				if [ -e "$RES/$_DEV" ]; then
					echo "$_DEV"
					break
				fi
		done

else
  		echo "$MDM"
fi

}

case $1 in
	"json")
		. /usr/share/libubox/jshn.sh
		json_init
		json_add_string modem "$(getmodem)"
		json_add_array
		json_close_array
		json_dump
		;;

esac

exit 0
