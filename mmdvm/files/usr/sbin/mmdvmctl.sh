#!/bin/sh /etc/rc.common
# 
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
# 
# The control script of mmdvm services
#

SERVICE_WRITE_PID=0
SERVICE_DAEMONIZE=0
EXTRA_COMMANDS="status update"                                                                                        
EXTRA_HELP="	status	Display status of mmdvm services
	update	Upgrade the mmdvm suite to lastest version" 

help() {
	cat <<EOF
Syntax: $initscript [command]

* This is the control script of mmdvm services (mmdvmhost, p25gateway, p25parrot, ysfgateway, ysfparrot).
* For pkg update, run 'mmdvmctl update'

Available commands:
	start	Start the mmdvm services
	stop	Stop the mmdvm services
	restart	Restart the mmdvm services
	enable	Enable mmdvm services autostart
	disable	Disable mmdvm services autostart
$EXTRA_HELP
EOF
}

_command() {
    /etc/init.d/mmdvmhost $1
    /etc/init.d/p25gateway $1
    /etc/init.d/p25parrot $1
    /etc/init.d/ysfgateway $1
    /etc/init.d/ysfparrot $1
    /etc/init.d/nxdngateway $1
    /etc/init.d/nxdnparrot $1
    /etc/init.d/ircddbgateway $1
    /etc/init.d/timeserver $1
    /etc/init.d/dmrid $1
    [ -f /etc/init.d/dapnetgateway ] && /etc/init.d/dapnetgateway $1
}

start() {
    _command start
}

stop() {
    _command stop
}

enable() {
    _command enable
}

disable() {
    _command disable
}

status() {
    _command status
}

update() {
    opkg update
    opkg upgrade mmdvm libmmdvm mmdvm-luci mmdvm-host p25-clients ysf-clients nxdn-clients ircddb-gateway

    installed=`opkg list-installed | grep luci-i18n-base-zh-cn`
    if [ -n "$installed" ]; then
        opkg upgrade luci-i18n-base-zh-cn mmdvm-luci-i18n-zh-cn
    fi

    installed=`opkg list-installed | grep luci-mod-admin-full`
    if [ -n "$installed" ]; then
        opkg upgrade luci-mod-admin-full
    fi
    
    installed=`opkg list-installed | grep luci-mod-admin-mmdvm`
    if [ -n "$installed" ]; then
        opkg upgrade luci-mod-admin-mmdvm
    fi

    installed=`opkg list-installed | grep dapnet-gateway`
    if [ -n "$installed" ]; then
        opkg upgrade dapnet-gateway
    fi
}
