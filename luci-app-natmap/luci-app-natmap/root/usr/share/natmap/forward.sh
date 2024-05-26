#!/bin/bash
# NATMap
outter_ip=$1
outter_port=$2
ip4p=$3
inner_port=$4
protocol=$5

# 如果$forward_target_port为空或者$forward_target_ip为空则退出
if [ -z "$FORWARD_TARGET_PORT" ] || [ -z "$FORWARD_TARGET_IP" ]; then
    exit 0
fi

forward_script=""
case $FORWARD_MODE in
"firewall")
    forward_script="/usr/share/natmap/plugin-forward/firewall-forward.sh"
    ;;
"ikuai")
    forward_script="/usr/share/natmap/plugin-forward/ikuai-forward.sh"
    ;;
*)
    forward_script=""
    ;;
esac

# # 如果$FORWARD_MODE非空则执行对应的脚本
# if [ -n "${FORWARD_MODE}" ]; then
#     forward_script="/usr/share/natmap/plugin-forward/${FORWARD_MODE}-forward.sh"
# fi

if [ -n "${forward_script}" ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $GENERAL_NAT_NAME execute forward script" >>/var/log/natmap/natmap.log
    bash "$forward_script" "$@"
fi
