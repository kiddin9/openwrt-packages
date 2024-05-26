#!/bin/sh
# Copyright 2023 Rafał Wabik (IceG) - From eko.one.pl forum
# Licensed to the GNU General Public License v3.0.

	DEV=$(uci -q get sms_tool_js.@sms_tool_js[0].readport)
	LEDX=$(uci -q get sms_tool_js.@sms_tool_js[0].smsled)
	MEM=$(uci -q get sms_tool_js.@sms_tool_js[0].storage)
	STX=$(sms_tool -s $MEM -d $DEV status | cut -c23-27)
	SMS=$(echo $STX | tr -dc '0-9')
	SMSC=$(uci -q get sms_tool_js.@sms_tool_js[0].sms_count)
	SMSD=$(echo $SMSC | tr -dc '0-9')
	LEDT="/sys/class/leds/$LEDX/trigger"
	LEDON="/sys/class/leds/$LEDX/delay_on"
	LEDOFF="/sys/class/leds/$LEDX/delay_off"

	TMON=$((1 * 1000))
	TMOFF=$((5 * 1000))

if [ $SMS == $SMSD ]; then

	exit 0
fi

if [ $SMS > $SMSD ]; then

echo timer > $LEDT
echo $TMOFF > $LEDOFF
echo $TMON > $LEDON
exit 0

fi


exit 0
