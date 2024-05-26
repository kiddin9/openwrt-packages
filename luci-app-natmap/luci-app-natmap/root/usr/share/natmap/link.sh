#!/bin/bash
# NATMap
outter_ip=$1
outter_port=$2
ip4p=$3
inner_port=$4
protocol=$5

link_script=""
# echo "LINK_MODE: $LINK_MODE"

# 如果$LINK_MODE非空则执行对应的脚本
if [ -n "${LINK_MODE}" ]; then
    link_script="/usr/share/natmap/plugin-link/${LINK_MODE}.sh"
fi

if [ -n "${link_script}" ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $GENERAL_NAT_NAME execute link script" >>/var/log/natmap/natmap.log
    bash "${link_script}" "$@"
fi
