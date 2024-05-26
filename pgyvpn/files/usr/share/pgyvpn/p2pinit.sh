#!/bin/sh

#删除oray_vpn_p2p表
iptables -w -t filter -F oray_vpn_p2p
while true;
do
	iptables -w -t filter -D INPUT -j oray_vpn_p2p 2>/dev/null
	[ $? -ne 0 ] && break
done
iptables -w -t filter -X oray_vpn_p2p

#建立oray_vpn_p2p表
iptables -w -t filter -N oray_vpn_p2p
iptables -w -t filter -I oray_vpn_p2p -p udp --dport $2 -j ACCEPT
iptables -w -t filter -I oray_vpn_p2p -p udp --dport 1900 -j ACCEPT
iptables -w -t filter -I INPUT 1 -j oray_vpn_p2p
