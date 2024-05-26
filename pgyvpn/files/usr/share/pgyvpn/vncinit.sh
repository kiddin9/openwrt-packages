#!/bin/sh

#删除oray_vpn_vnc表
iptables -w -t filter -F oray_vpn_vnc
while true;
do
	iptables -w -t filter -D INPUT -j oray_vpn_vnc 2>/dev/null
	[ $? -ne 0 ] && break
done

while true;
do
	iptables -w -t filter -D FORWARD -j oray_vpn_vnc 2>/dev/null
	[ $? -ne 0 ] && break
done

while true;
do
	iptables -w -t filter -D OUTPUT -j oray_vpn_vnc 2>/dev/null
	[ $? -ne 0 ] && break
done
iptables -w -t filter -X oray_vpn_vnc

#建立oray_vpn_vnc表
iptables -w -t filter -N oray_vpn_vnc
iptables -w -t filter -I oray_vpn_vnc -i oray_vnc -o br-lan -j ACCEPT
iptables -w -t filter -I oray_vpn_vnc -o oray_vnc -i br-lan -j ACCEPT
iptables -w -t filter -I INPUT 1 -j oray_vpn_vnc
iptables -w -t filter -I OUTPUT 1 -j oray_vpn_vnc
iptables -w -t filter -I FORWARD 1 -j oray_vpn_vnc
iptables -w -t filter -I oray_vpn_vnc -i oray_vnc -j ACCEPT
