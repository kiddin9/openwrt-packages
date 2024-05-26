#!/bin/sh
WOLIFACE=$1
HWADDR=$2
if [ -z $WOLIFACE ]  && [ -z "$HWADDR" ]; then
	echo -en "Usage: */wol {interface} {hwadddress}*"
else
	/usr/bin/etherwake -D -i "$WOLIFACE" "$HWADDR"
fi
