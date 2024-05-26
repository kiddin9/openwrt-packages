#!/bin/sh
. /lib/functions.sh
. /lib/netifd/netifd-proto.sh


find_fm350_iface() {
	local cfg="$1"
	local proto
	config_get proto "$cfg" proto
	[ "$proto" = fm350 ] || return 0
	if [ "$ACTION" = remove ]; then
		proto_set_available "$cfg" 0
	fi
	if [ "$ACTION" = add ]; then 
	        proto_set_available "$cfg" 1
	fi
}

if [ "$PRODUCT" = 'e8d/7126/1' ] && [ "$ACTION" = add ]; then
    echo "0e8d 7126 ff" > /sys/bus/usb-serial/drivers/option1/new_id
fi

if [ "$PRODUCT" = 'e8d/7127/1' ] && [ "$ACTION" = add ]; then
    echo "0e8d 7127 ff" > /sys/bus/usb-serial/drivers/option1/new_id
fi

config_load network
config_foreach find_fm350_iface interface
