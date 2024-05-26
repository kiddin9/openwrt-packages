#!/bin/sh
[ $# -lt 1 -o -n "${2//[0-3]/}" -o ${#2} -gt 1 ] && {
	echo -e "\n  USAGE:"
	echo -e "  ${0} [SECTION] [VERBOSE_MODE]\n"
	echo    "  [SECTION]      - service section as defined in /etc/config/autorepeater.global.interface"
	echo    "  [VERBOSE_MODE] - '0' NO output to console"
	echo    "                   '1' output to console"
	echo    "                   '2' output to console AND logfile"
	echo    "                       + run once WITHOUT retry on error"
	echo    "                   '3' output to console AND logfile"
	echo    "                       + run once WITHOUT retry on error"
	echo -e "                       + NOT sending update to AutoRepeater service\n"
	exit 1
}
#set -x
. /usr/lib/autorepeater/autorepeater_functions.sh
#/etc/config/autorepeater
config_load "autorepeater"
#reload after interface setted /called from daemon process starting
load_all_config_options "autorepeater" "global"
ERR_LAST=$?

SECTION_ID="${1:-global}"
if [ "${1}" == "global" ] ;then
#for no interface specified
	isec=""
	config_get_first_list_val "interface" "global" "interface"
else
	isec="-${1}"
	interface="${1}"
fi
__IFACE=${interface:-wan}

VERBOSE_MODE=${2:-1}
PIDFILE="${RUNDIR}/${SECTION_ID}.pid"
UPDFILE="${RUNDIR}/${SECTION_ID}.update"
DATFILE="${RUNDIR}/${SECTION_ID}.dat"
DEVFILE="${RUNDIR}/${SECTION_ID}.dev"
ERRFILE="${RUNDIR}/${SECTION_ID}.err"
LOGFILE="${LOGDIR}/${SECTION_ID}.log"
[ ${VERBOSE_MODE} -gt 1 -a -f ${LOGFILE} ] && rm -f ${LOGFILE}
#should avoid foreach loop return trap_handle for aborting the loop
trap "trap_handler 0 \$?" 0
trap "trap_handler 1"  1
trap "trap_handler 2"  2
trap "trap_handler 3"  3
trap "trap_handler 15" 15
################################################################################
################################################################################
[ ${ERR_LAST} -ne 0 ] && {
	[ ${VERBOSE_MODE} -le 1 ] && VERBOSE_MODE=2
	[ -f ${LOGFILE} ] && rm -f ${LOGFILE}
	write_log  7 "************ ************** ************** **************"
	write_log  5 "PID '$$' started at $(eval ${DATE_PROG})"
	write_log  7 "uci configuration:\n$(uci -q show autorepeater | grep '=autorepeater' | sort)"
	write_log 14 "Service section '${SECTION_ID}' not defined"
}

write_log 7 "************ ************** ************** **************"
write_log 5 "PID '$$' started at $(eval ${DATE_PROG})"
if [ -z "${interface}" ]; then
	write_log 7 "uci configuration:\nautorepeater.${SECTION_ID}.interface='${__IFACE}'\n$(uci -q show autorepeater.${SECTION_ID} | sort)"
else
	write_log 7 "uci configuration:\n$(uci -q show autorepeater.${SECTION_ID} | sort)"
fi
write_log 7 "autorepeater version  : $(opkg list-installed luci-app-autorepeater | cut -d ' ' -f 3)"
write_log 7 "miniupnpc version     : $(opkg list-installed miniupnpc | cut -d ' ' -f 3)"
case ${VERBOSE_MODE} in
	0) write_log  7 "verbose mode    : 0 - run normal, NO console output";;
	1) write_log  7 "verbose mode    : 1 - run normal, console mode";;
	2) write_log  7 "verbose mode    : 2 - run once, NO retry on error";;
	3) write_log  7 "verbose mode    : 3 - run once, NO retry on error, NOT sending update";;
	*) write_log 14 "error detecting VERBOSE_MODE '${VERBOSE_MODE}'";;
esac
case ${associate_order:=0} in
	0) write_log  7 "associate order : 0 - by signal strengh";;
	1) write_log  7 "associate order : 1 - by list order";;
	*) write_log  7 "associate order : * - by seached order";;
esac
[ "${associate_order}" -ne 0 ] && a_band_first="0"
case ${a_band_first:=1} in
	0) write_log  7 "\"A\" band first  : 0 - a band as normal";;
	1) write_log  7 "\"A\" band first  : 1 - take \"A\" band first";;
	*) write_log  7 "\"A\" band first  : * - a band as normal";;
esac

write_log  7 "scan percent    : ${scanpercent=15}"  
write_log  7 "mini percent    : ${minipercent=50}"
write_log  7 "dhcp timeout    : ${dhcp_timeout=20}"
write_log  7 "ping host       : ${ping_host=www.baidu.com}"

get_seconds CHECK_SECONDS ${check_interval:-5} ${check_unit:-"minutes"}
get_seconds FORCE_SECONDS ${force_interval:-12} ${force_unit:-"hours"}
get_seconds RETRY_SECONDS ${retry_interval:-30} ${retry_unit:-"seconds"}
[ ${CHECK_SECONDS} -lt 300 ] && CHECK_SECONDS=300
[ ${FORCE_SECONDS} -gt 0 -a ${FORCE_SECONDS} -lt ${CHECK_SECONDS} ] && FORCE_SECONDS=${CHECK_SECONDS}
write_log 7 "check interval  : ${CHECK_SECONDS} seconds"
write_log 7 "force interval  : ${FORCE_SECONDS} seconds"
write_log 7 "retry interval  : ${RETRY_SECONDS} seconds"
write_log 7 "retry counter   : ${retry_count:-0} times"

stop_autorepeater_interface "${SECTION_ID}"
[ $? -gt 0 ] && write_log 7 "'SIGTERM' was send to old process" || write_log 7 "No old process"
echo $$ > ${PIDFILE}
get_uptime CURR_TIME
[ -e "${UPDFILE}" ] && {
	LAST_TIME=$(cat ${UPDFILE})
	[ -z "${LAST_TIME}" ] && LAST_TIME=0
	[ ${LAST_TIME} -gt $CURR_TIME ] && LAST_TIME=0
}
if [ ${LAST_TIME} -eq 0 ]; then
	write_log 7 "Last associated: never"
else
	EPOCH_TIME=$(( $(date +%s) - CURR_TIME + LAST_TIME ))
	EPOCH_TIME="date -d @${EPOCH_TIME} +'${DATE_FORMAT}'"
	write_log 7 "Last associated: $(eval ${EPOCH_TIME})"
fi
[ -n "${proxy}" ] && {
	verify_proxy "${proxy}" && {
		export HTTP_PROXY="http://${proxy}"
		export HTTPS_PROXY="http://${proxy}"
		export http_proxy="http://${proxy}"
		export https_proxy="http://${proxy}"
	}
}
site_survey_and_association() {
	#for resort scanned station by signal strengh
	local BY_SEGNAL_ORDER_DEFAULTS=3
	local ASSOCIATED=0 _MATCH=0 _TRIES=0
	mv -f "${RUNDIR}/now_scan" "${RUNDIR}/last_scan" 2>/dev/null
	mv -f "${RUNDIR}/now_matched" "${RUNDIR}/last_matched" 2>/dev/null
	#result to log path
	write_log 5 "Scanning ..."
	site_survey "${RUNDIR}/now_scan"
	ERR_LAST=$?
	if [ "${ERR_LAST}" -gt 0 ]; then
		write_log 6 "Filter by list ..."
		#run by timestamped section name /strengh+system()+10000*rand()/
		append_diff_ucipath_cfg_and_run dump_available_station_from_loaded "${BY_SEGNAL_ORDER_DEFAULTS}" "autorepeater" "${RUNDIR}" "now_scan" "wifi-scan" "wifi-station${isec}" "now_matched" _MATCH
		if [ "${_MATCH}" -gt 0 ]; then
			#run by saved order
			append_diff_ucipath_cfg_and_run build_trying_list_from_loaded "${associate_order}" "autorepeater" "${RUNDIR}" "now_matched" "wifi-scan" "wifi-station${isec}" "matched" _MATCH
			write_log 5 "Prepared matched: [ ${_MATCH} ]"
			trying_association "${RUNDIR}" "matched" _TRIES
			ASSOCIATED=$?
			#[ "${ASSOCIATED}" -eq 0 ] || portmapping_trying "pnp-mapping" "global" "root_url"
			write_log 5 "Matched tries:    [ ${_TRIES} / ${_MATCH} ]"
		else
			write_log 4 "Zero matched station"
		fi
	else
		write_log 2 "Failed in scanning"
		write_log 7 "Scanning returns:\n$(cat ${ERRFILE})"
	fi
	return ${ASSOCIATED}
}

[ -z "${retry_count}" ]	  && retry_count=0

while : ; do
	[ "$mwifi_enabled" == "1" ] || write_log 14 "Service section disabled by settings!"
	pingout PING_OUT 1
	[ ${FORCE_SECONDS} -eq 0 -o ${LAST_TIME} -eq 0 ] \
		&& NEXT_TIME=0 \
		|| NEXT_TIME=$(( ${LAST_TIME} + ${FORCE_SECONDS} ))
	get_uptime CURR_TIME
	if [ $CURR_TIME -ge ${NEXT_TIME} -o ${PING_OUT} -ne 0 ]; then
		if [ ${VERBOSE_MODE} -gt 2 ]; then
			write_log 7 "Verbose Mode: ${VERBOSE_MODE} - NO ASSOCIATION perform"
		elif [ ${PING_OUT} -ne 0 ]; then
			write_log 2 "Re-association needed."
		else
			write_log 2 "Forced Update."
		fi
		ASSOCIATED=0
		[ ${VERBOSE_MODE} -lt 3 ] && {
			site_survey_and_association
			ASSOCIATED=$?
		}
		if [ ${ASSOCIATED} -ne 0 ]; then
			get_uptime LAST_TIME
			echo ${LAST_TIME} > ${UPDFILE}
			pingout PING_OUT
			[ ${PING_OUT} -eq 0 ] && write_log 6 "Update successful"
		else
			write_log 3 "Can not associate any stations in list or ping timer out."
		fi
	else
		ASSOCIATED=1
	fi
	if [ ${ASSOCIATED} -eq 0 ]; then
		write_log 7 "Waiting ${RETRY_SECONDS} seconds (Retry Interval)"
		cat /etc/config/wireless.fs > /etc/config/wireless
		reload_wifi
		dhcp_recheck
		sleep ${RETRY_SECONDS} &
	else
		write_log 7 "Waiting ${CHECK_SECONDS} seconds (Check Interval)"
		dhcp_recheck
		sleep ${CHECK_SECONDS} &
	fi
	PID_SLEEP=$!
	wait ${PID_SLEEP}
	PID_SLEEP=0

	#pingout PING_OUT
	if [ ${PING_OUT} -ne 0 ]; then
		if [ ${VERBOSE_MODE} -le 1 ]; then
			ERR_UPDATE=$(( ${ERR_UPDATE} + 1 ))
			[ ${retry_count} -gt 0 -a ${ERR_UPDATE} -gt ${retry_count} ] && \
				write_log 14 "Station association failed after ${retry_count} retries"
			write_log 4 "Station association failed - starting retry ${ERR_UPDATE}/${retry_count}"
			continue
		else
			write_log 4 "Station association failed"
			write_log 7 "Verbose Mode: ${VERBOSE_MODE} - NO retry"; exit 1
		fi
	else
		ERR_UPDATE=0
		ASSOCIATED=1
	fi
	[ ${VERBOSE_MODE} -gt 1 ]  && write_log 7 "Verbose Mode: ${VERBOSE_MODE} - NO reloop"
	[ ${FORCE_SECONDS} -eq 0 ] && write_log 6 "Configured to run once"
	[ ${VERBOSE_MODE} -gt 1 -o ${FORCE_SECONDS} -eq 0 ] && exit 0
#	write_log 6 "Rerun station association at $(eval $DATE_PROG)"
done

write_log 12 "Error in 'autorepeater_updater.sh - program coding error"
