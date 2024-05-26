#!/bin/sh

CONFIG_BASE="/usr/share/homebridge/devices/"

if [ -z $1 ]
then
    echo "Need a section argument"
	exit 1
fi

pid_path=$CONFIG_BASE/$1/homebridge.pid
echo $pid_path
if [ -f $pid_path ];then
	pid_number=$(cat $pid_path)
	if [ -d /proc/$pid_number ];then
		exit 0
	else
		exit 1
	fi
else
	exit 1
fi
