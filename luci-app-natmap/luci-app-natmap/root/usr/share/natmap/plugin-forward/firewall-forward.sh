#!/bin/bash
# NATMap
outter_ip=$1
outter_port=$2
ip4p=$3
inner_port=$4
protocol=$5

# if [ "$FORWARD_MODE" != firewall ]; then
# 	exit 0
# fi

# 如果$forward_target_port为空则退出
if [ -z "$FORWARD_TARGET_PORT" ]; then
	# echo "FORWARD_TARGET_PORT is empty,firewall forward exit"
	exit 0
fi

# 如果$forward_target_ip为空则退出
if [ -z "$FORWARD_TARGET_IP" ]; then
	# echo "FORWARD_TARGET_IP is empty"
	exit 0
fi

# get forward target port
final_forward_target_port=$((FORWARD_TARGET_PORT == 0 ? outter_port : FORWARD_TARGET_PORT))
# echo "firewall_final_forward_target_port: $final_forward_target_port"

# ipv4 firewall
rule_name_v4=$(echo "${GENERAL_NAT_NAME}_v4" | sed 's/[^a-zA-Z0-9]/_/g' | awk '{print tolower($0)}')
echo "firewall_rule_name_v4: $rule_name_v4" >>/var/log/natmap/natmap.log

# ipv4 redirect
uci set firewall.$rule_name_v4=redirect
uci set firewall.$rule_name_v4.name=$rule_name_v4
uci set firewall.$rule_name_v4.proto=$protocol
uci set firewall.$rule_name_v4.src=$GENERAL_WAN_INTERFACE
uci set firewall.$rule_name_v4.dest=$FORWARD_FIREWALL_TARGET_INTERFACE
uci set firewall.$rule_name_v4.target=DNAT
uci set firewall.$rule_name_v4.src_dport=$inner_port
uci set firewall.$rule_name_v4.dest_ip=$FORWARD_TARGET_IP
uci set firewall.$rule_name_v4.dest_port=$final_forward_target_port

# reload
uci commit firewall
/etc/init.d/firewall reload

# --------------------------------------------------------------------------------------------
# QB and TR ipv6 forward
# 检测link_enable
if [ "${LINK_ENABLE}" != 1 ]; then
	echo "$GENERAL_NAT_NAME - $FORWARD_MODE: LINK_ENABLE is not 1, exit, don't forward ipv6" >>/var/log/natmap/natmap.log
	exit 0
fi

if [ [ "${LINK_MODE}" = transmission ] && [ "${LINK_TR_ALLOW_IPV6}" = 1 ] ] || [ [ "${LINK_MODE}" = qbittorrent ] && ["${LINK_QB_ALLOW_IPV6}" != 1 ] ]; then

	# get rule name
	rule_name_v6=$(echo "${GENERAL_NAT_NAME}_v6_allow" | sed 's/[^a-zA-Z0-9]/_/g' | awk '{print tolower($0)}')

	echo "$GENERAL_NAT_NAME - $FORWARD_MODE: firewall_rule_name_v6: $rule_name_v6" >>/var/log/natmap/natmap.log
	# ipv6 allow
	uci set firewall.$rule_name_v6=rule
	uci set firewall.$rule_name_v6.name=$rule_name_v6
	uci set firewall.$rule_name_v6.src=$GENERAL_WAN_INTERFACE
	uci set firewall.$rule_name_v6.dest=$FORWARD_FIREWALL_TARGET_INTERFACE
	uci set firewall.$rule_name_v6.target=ACCEPT
	uci set firewall.$rule_name_v6.proto=$protocol
	uci set firewall.$rule_name_v6.family=ipv6
	uci set firewall.$rule_name_v6.dest_port=$final_forward_target_port

	# check if dest_ip is already set with return code
	if uci get firewall.$rule_name_v6.dest_ip >/dev/null 2>&1; then
		uci del firewall.$rule_name_v6.dest_ip
	fi

	# add dest_ip list
	case "${LINK_MODE}" in
	"transmission")
		for ip in $LINK_TR_IPV6_ADDRESS; do
			uci add_list firewall.$rule_name_v6.dest_ip=$ip
		done
		;;
	"qbittorrent")
		for ip in $LINK_QB_IPV6_ADDRESS; do
			uci add_list firewall.$rule_name_v6.dest_ip=$ip
		done
		;;
	esac
	# reload
	uci commit firewall
	/etc/init.d/firewall reload

fi
