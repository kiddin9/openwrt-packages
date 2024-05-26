#!/bin/sh

INTERFACE="$1"

if [ -n "$INTERFACE" ]; then
	echo -en "\`\`\`$(ifconfig $INTERFACE)\`\`\`"
else
	echo -en "Usage: */ifconfig {interface}*"
fi
