#!/bin/sh
#
#walkingsky
#tangxn_1@163.com

local run=`ps  | grep  "wifidog -c /tmp/wifidog.conf"  | wc -l`
	
if [ $run -lt 2 ]; then
	wifidog -c /tmp/wifidog.conf	
fi