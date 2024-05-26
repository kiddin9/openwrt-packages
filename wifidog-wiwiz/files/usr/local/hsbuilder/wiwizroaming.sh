#!/bin/sh
# Wiwiz HotSpot Builder Utility
# Copyright wiwiz.com. All rights reserved.

MY_VERSION="3.0.0"	#for Wiwiz-opensource

SRV_SAVE='/usr/local/hsbuilder/srv'
ROAMING_FILE='/tmp/wiwizroaming'
HID=""
TMPFILE='/tmp/hsbuilder_token.tmp'
DEBUG_FILE='/tmp/wiwizroaming.debug'
LOGFILE='/tmp/hsbuilder.log'

debug() {
	DEBUG=$(cat "$DEBUG_FILE" 2>/dev/null)
	if [ "$DEBUG" = "1" ]; then
		echo "$1" >>$LOGFILE
	fi
}

getIP() {
	mac="$1"	
	
	for i in $(seq 6); do	
		s=$(cat /proc/net/arp | grep -F 'br-lan' | grep -F "$mac" | grep -F '0x2')
		if [ "$s" = "" ]; then
			sleep 1
			continue
		else
			echo "$s"
			break
		fi
	done
	
	return
}

doAuth() {
	MAC="$1"
	AS_HOSTNAME_X="$2"

    URL="http://$AS_HOSTNAME_X/as/s/auth/?stage=token&gw_id=$HID&mac=$MAC"
    
	debug "HID=$HID"

	rm -f "$TMPFILE"
	curl -m 10 -o "$TMPFILE" "$URL"	
	token=$(cat "$TMPFILE" 2>/dev/null |  cut -d ':' -f 2)
	ip=$(cat "$TMPFILE" 2>/dev/null |  cut -d ':' -f 3)
	rm -f "$TMPFILE"

    if [ "$ip" != "" ]; then
		ping -c4 "$ip" 2>/dev/null &
    fi
    	
    IP=$(getIP "$MAC" | awk '{print $1}')
    if [ "$IP" = "" ]; then
    	return
    fi
    
	debug "IP=$IP"
	
	if [ "$token" = "" ]; then
		return
	fi
	
	wdctl auth "$MAC" "$IP" "$token"
	debug "wdctl auth $MAC $IP $token"

	wdctl status | grep 'IP:' | grep 'MAC:' | tr -d ' ' | sed 's/IP://g' | sed 's/MAC:/ /g' | grep -i "$MAC" | grep -v "$IP " | while read LINE; do
		IPtoReset=$(echo "$LINE" | cut -d ' ' -f 1)
		wdctl reset "$IPtoReset"
		debug "wdctl reset $IPtoReset"
	done
}


logread -f | while read LINE; do
        s=$(echo "$LINE" | grep hostapd | grep STA | grep -F ' associated')
				
        if [ "$s" != "" ]; then
				debug "s=$s"
				HID=$(uci get wiwiz.portal.hotspotid | xargs 2>/dev/null)
				if [ "$HID" = "" ]; then
					continue
				fi
				
				ROAMING=$(cat "$ROAMING_FILE" 2>/dev/null)
				if [ "$ROAMING" = "" ]; then
					continue
				fi

				AS_HOSTNAME_X=$(uci get wiwiz.portal.server 2>/dev/null)
				if [ "$AS_HOSTNAME_X" = "" ]; then
					continue
				fi

                MAC=$(echo "$LINE" | awk '{print $10}')
                if [ "$MAC" = "" ]; then
                	continue
                fi
				debug "MAC=$MAC"				
                doAuth "$MAC" "$AS_HOSTNAME_X" &
        fi
done
