#!/bin/sh
# Copyright 2023 Rafał Wabik (IceG) - From eko.one.pl forum
# Licensed to the GNU General Public License v3.0.

sleep 2

[ -e /etc/crontabs/root ] || touch /etc/crontabs/root

SLED=$(uci -q get sms_tool_js.@sms_tool_js[0].lednotify)
if [ "x$SLED" != "x1" ]; then
	if grep -q "my_new_sms" /etc/crontabs/root; then
		grep -v "/etc/init.d/my_new_sms" /etc/crontabs/root > /tmp/new_cron
		mv /tmp/new_cron /etc/crontabs/root
		/etc/init.d/cron restart
	fi
	exit 0
fi

if ! grep -q "my_new_sms" /etc/crontabs/root; then
PTR=$(uci -q get sms_tool_js.@sms_tool_js[0].prestart)
	echo "1 */$PTR * * *  /etc/init.d/my_new_sms enable && /etc/init.d/my_new_sms restart" >> /etc/crontabs/root
	/etc/init.d/cron restart
fi

exit 0
