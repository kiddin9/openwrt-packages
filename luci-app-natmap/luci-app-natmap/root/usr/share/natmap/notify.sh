#!/bin/bash
# NATMap
outter_ip=$1
outter_port=$2
ip4p=$3
inner_port=$4
protocol=$(echo $5 | tr 'a-z' 'A-Z')

msg="${GENERAL_NAT_NAME}
New ${protocol} port mapping: ${inner_port} -> ${outter_ip}:${outter_port}
IP4P: ${ip4p}"
if [ ! -z "$MSG_OVERRIDE" ]; then
	msg="$MSG_OVERRIDE"
fi

# notify_mode 判断
notify_script=""
# case $NOTIFY_MODE in
# "telegram_bot")
# 	notify_script="/usr/share/natmap/plugin-notify/telegram_bot.sh"
# 	;;
# "pushplus")
# 	notify_script="/usr/share/natmap/plugin-notify/pushplus.sh"
# 	;;
# "serverchan")
# 	notify_script="/usr/share/natmap/plugin-notify/serverchan.sh"
# 	;;
# "gotify")
# 	notify_script="/usr/share/natmap/plugin-notify/gotify.sh"
# 	;;
# *)
# 	notify_script=""
# 	;;
# esac

# 如果$NOTIFY_MODE非空则执行对应的脚本
if [ -n "${NOTIFY_MODE}" ]; then
	notify_script="/usr/share/natmap/plugin-notify/$NOTIFY_MODE.sh"
fi

if [ -n "${notify_script}" ]; then
	echo "$(date +'%Y-%m-%d %H:%M:%S') - $GENERAL_NAT_NAME execute notify script" >>/var/log/natmap/natmap.log
	bash "$notify_script" "$msg"
fi
