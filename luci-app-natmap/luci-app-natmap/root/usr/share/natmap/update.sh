#!/bin/sh

. /usr/share/libubox/jshn.sh

(
	json_init
	json_add_string ip "$1"
	json_add_int port "$2"
	json_add_string ip4p "$3"
	json_add_int inner_port "$4"
	json_add_string protocol "$5"
	json_add_string name "$GENERAL_NAT_NAME"
	json_dump >/var/run/natmap/$PPID.json
)

# 设置日志参数
log_size_limit=1024000
log_file="/var/log/natmap/natmap.log"
# natmap logs setting
# 日志大小限制超过1M则删除最早的日志，若日志不存在则创建日志文件
if [ -f "/var/log/natmap/natmap.log" ]; then
	[ "$(wc -c /var/log/natmap/natmap.log | awk '{print $1}')" -gt "${log_size_limit}" ] && {
		[ -f "/var/log/natmap/natmap.log.1" ] && {
			rm -f /var/log/natmap/natmap.log.1
		}
		mv /var/log/natmap/natmap.log /var/log/natmap/natmap.log.1
	}
else
	[ ! -d "/var/log/natmap" ] && {
		mkdir -p /var/log/natmap
	}
	touch /var/log/natmap/natmap.log
fi

echo "$(date +'%Y-%m-%d %H:%M:%S') - natmap update json: $(cat /var/run/natmap/$PPID.json)"

# forward setting
[ "${FORWARD_ENABLE}" == 1 ] && source /usr/share/natmap/forward.sh "$@"

# link setting
[ "${LINK_ENABLE}" == 1 ] && source /usr/share/natmap/link.sh "$@"

# custom setting
[ "${CUSTOM_SCRIPT_ENABLE}" == 1 ] && [ -n "${CUSTOM_SCRIPT_PATH}" ] && {
	export -n CUSTOM_SCRIPT_PATH
	source "${CUSTOM_SCRIPT_PATH}" "$@"
}

# notify setting
[ "${NOTIFY_ENABLE}" == 1 ] && source /usr/share/natmap/notify.sh "$@"
