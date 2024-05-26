#!/bin/sh
. /lib/functions.sh
. /lib/netifd/netifd-proto.sh


find_xmm_iface() {
	local cfg="$1"
	local proto
	config_get proto "$cfg" proto
	[ "$proto" = xmm ] || return 0
	if [ "$ACTION" = remove ]; then
		proto_set_available "$cfg" 0
	fi
	if [ "$ACTION" = add ]; then 
	        proto_set_available "$cfg" 1
	fi
}

config_load network
config_foreach find_xmm_iface interface
