#!/bin/sh
. /usr/share/libubox/jshn.sh

json_load "$(ubus call system board)" 2>/dev/null
json_get_var var1 "model" 2>/dev/null

echo "$var1"