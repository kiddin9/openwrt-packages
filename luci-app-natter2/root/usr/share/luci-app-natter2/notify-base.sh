#!/bin/sh

protocol="$1"; private_ip="$2"; private_port="$3"; public_ip="$4"; public_port="$5"

script_name=$(basename $0)
script_path=$(dirname $0)
instance_id=$(echo $script_name | cut -d '-' -f1)
instance_num=$(echo $script_name | cut -d '-' -f2)
instance_isnotify=$(echo $script_name | cut -d '-' -f3)

# echo script_path:$script_path
# echo script_name:$script_name
# echo instance_id:$instance_id
# echo instance_num:$instance_num
# echo instance_isnotify:$instance_isnotify

uci set natter2.@instances[$instance_num].tmp_public_port="$public_port"
uci commit natter2

if [ "$instance_isnotify" == 1 ]
then
	notify_path=$(cat $script_path/${instance_id}-notify)
	if [ -f "${notify_path}" ]
	then
		chmod +x ${notify_path}
		${notify_path} $1 $2 $3 $4 $5
	fi
fi
