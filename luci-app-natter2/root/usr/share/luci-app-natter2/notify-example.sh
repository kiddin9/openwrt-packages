#!/bin/sh

# 参数序号		参数说明		参数格式
#	1		传输层协议		tcp, udp 二者之一
#	2		内部 IP		点分十进制 IPv4 地址
#	3		内部端口		1 - 65535 的整数
#	4		外部 IP		点分十进制 IPv4 地址
#	5		外部端口		1 - 65535 的整数

protocol="$1"; private_ip="$2"; private_port="$3"; public_ip="$4"; public_port="$5"

echo $1 $2 $3 $4 $5
