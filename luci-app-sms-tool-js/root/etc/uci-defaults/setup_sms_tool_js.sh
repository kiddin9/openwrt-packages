#!/bin/sh
# Copyright 2023 Rafał Wabik (IceG) - From eko.one.pl forum
# Licensed to the GNU General Public License v3.0.

chmod +x /sbin/sms_led.sh 2>&1 &
chmod +x /sbin/smstool_led.sh 2>&1 &
chmod +x /sbin/new_cron_sync.sh 2>&1 &
chmod +x /etc/uci-defaults/off_sms.sh 2>&1 &
chmod +x /etc/uci-defaults/setup_sms_tool_js.sh 2>&1 &
chmod +x /etc/init.d/my_new_sms 2>&1 &

rm -rf /tmp/luci-indexcache  2>&1 &
rm -rf /tmp/luci-modulecache/  2>&1 &
exit 0
