#!/bin/sh
#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
#.Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
. /lib/functions.sh
. /etc/diag.sh
. /lib/functions/network.sh
#ubus iwinfo
. /usr/share/libubox/jshn.sh
#from gargoyle /www/
. /usr/lib/autorepeater/scan_wifi.sh


UCI_CONFIG_DIR=""
SECTION_ID=""
VERBOSE_MODE=1
LOGFILE=""
PIDFILE=""
UPDFILE=""
DATFILE=""
ERRFILE=""
CHECK_SECONDS=0
FORCE_SECONDS=0
RETRY_SECONDS=0
LAST_TIME=0
CURR_TIME=0
NEXT_TIME=0
EPOCH_TIME=0
REGISTERED_IP=""
LOCAL_IP=""
URL_USER=""
URL_PASS=""
ERR_LAST=0
ERR_UPDATE=0
PID_SLEEP=0
RUNDIR=$(uci -q get autorepeater.global.run_dir) || RUNDIR="/var/run/autorepeater"
[ -d $RUNDIR ] || mkdir -p -m755 $RUNDIR
LOGDIR=$(uci -q get autorepeater.global.log_dir) || LOGDIR="/var/log/autorepeater"
[ -d $LOGDIR ] || mkdir -p -m755 $LOGDIR

LOGLINES=$(uci -q get autorepeater.global.log_lines) || LOGLINES=250
LOGLINES=$((LOGLINES + 1))
DATE_FORMAT=$(uci -q get autorepeater.global.date_format) || DATE_FORMAT="%F %R"
DATE_PROG="date +'$DATE_FORMAT'"
HTML_LOG=$(uci get autorepeater.global.html_page) || HTML_LOG="autorepeater.html"
HTML_LOG="$(uci get uhttpd.main.home)/$HTML_LOG"

IPV4_REGEX="[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"
IPV6_REGEX="\(\([0-9A-Fa-f]\{1,4\}:\)\{1,\}\)\(\([0-9A-Fa-f]\{1,4\}\)\{0,1\}\)\(\(:[0-9A-Fa-f]\{1,4\}\)\{1,\}\)"

ERROR_MEM_EMPTY=1
ERROR_MEM_TYPE=2
WARN_DISABLED_KNOWN=3
WARN_WEAK_KNOWN=4
NOT_MATCH_WEAK=5
NOT_MATCH_HEALTH=6
ERROR_NO_CATCH=7

[ "$(basename $0)" = "autorepeater_lucihelper.sh" ] && LUCI_HELPER="TRUE" || LUCI_HELPER=""
USE_CURL=$(uci -q get autorepeater.global.use_curl) || USE_CURL=0
[ -x /usr/bin/curl ] || USE_CURL=0
#for rfkill.sh
load_wireless() {
	mode="$(uci get wireless.${1}.mode)"
	[ "$mode" = "ap" ] || return 0
	if [ ! ${disabled+1} ] ; then
	disabled="$(uci get wireless.${1}.disabled)"
	if [ "$disabled" = "1" ]
		then
			changeto="0"
			str_led_state="done"
		else
			changeto="1"
			str_led_state="failsafe"
		fi
	fi
	set_wifi $1 $changeto

}
set_wifi() {
	[ "$device" = "all" -o "$device" = "${1}" ] && {
		uci set "wireless.${1}.disabled=${2}"
	}
}
reload_wifi() {
	/sbin/wifi reload
}
#status_get <dst> <_id> <item>
__status_get(){
	local __tmp
	[ -z "${DATA}" ] && return 0
	__tmp="$(jsonfilter -s "${DATA}" -e "${1}=@.status[@.id='${2}'].${3}")"
	[ -z "${__tmp}" ] && \
		unset "${1}" && \
		return 1
	eval "${__tmp}"
}
#update_secs_status <section_id> <type_name> <item> <value>
#name=LastMap/LastSignal/Realcipher/LastConn
#[{"id":"<section_id>._<LastMap>","name":"type_name","fail":"fail_time","ok":"successful_time"},
#{"bssid":"11:22:33:44:55:66","signal":"60"},
#{"encryption":"scan_encryption"},
#{"fail":"fail_time","ok":"successful_time"}]
#update_secs_status "${_key}" "LastConn" "ok" "$(eval ${DATE_PROG})"
update_secs_status() {
	[ "$#" -eq 4 ] || return 0
	local section_id="${1}"; shift 1
	local type_name="${1}"; shift 1
	local item="${1}"; shift 1
	local value="${1}"; shift 1

	local secs_status_file="${LOGDIR}/secs_status"
	local DATA=""
	local ERR_LAST=1
	local type _key _id _dsp keys exists
	#value with dot . not support???
	local _id="${section_id}._${type_name}"

	DATA="$(cat ${secs_status_file})"
	json_init
	json_load "${DATA}"
	json_get_type type "status"
	ERR_LAST=$?
	json_select "status" 2>/dev/null
	if [ "${ERR_LAST}" -ne 0 -o "${type}" != "array" ]; then
		json_init
		json_add_array "status"
		rm -rf "${secs_status_file}"
	fi
	#DATA=$(json_dump)
	#eval $(jsonfilter -s "${DATA}" -F',' -l "5" -e "dsp=@.status[@.section_id='HTTP'].name")
	#eval $(jsonfilter -s "${DATA}" -e "dsp=@.status[@.section_id='HTTP'].name")
	#echo $dsp
	#__status_get "_dsp" "${_id}" "${item}"
	#if [ -z "${_dsp}" ]; then
	#	json_add_object ""
	#	json_add_string "id" "${_id}"
	#	json_add_string "${item}" "${value}"
	#	json_close_object
	#else
		exists=0
		json_get_keys keys
		if [ "${keys}" != "" ]; then
			for _key in ${keys}; do
				json_select ${_key}
				json_get_var "_dsp" "id"
				if [ "x${_dsp}" = "x${_id}" ]; then
					exists=1
					json_select ..
					break
				fi
				json_select ..
			done
		fi
		if [ "${exists}" -eq 1 ]; then
			json_select ${_key}
			json_add_string "${item}" "${value}"
			json_select ..
		else
			json_add_object
			json_add_string "id" "${_id}"
			json_add_string "name" "${type_name}"
			json_add_string "${item}" "${value}"
			json_close_object
		fi
	#fi
	[ "${ERR_LAST}" -ne 0 -o "${type}" != "array" ] && json_close_array
	json_dump 2>/dev/null >"${secs_status_file}"
	#DATA=$(json_dump 2>/dev/null)
	#jsonfilter -s "${DATA}" -e "$.status" -q >"${secs_status_file}"

	json_cleanup
	unset DATA
}
##https://github.com/OnionIoT/wifisetup/blob/master/wifisetup.sh
#__dev_master_info <src> <dst> [name]
#__dev_master_info "INFO" "__ifs" "phy"
#__dev_master_info "INFO" "__hwmodes"
#b g n
#if [[ $(list_contains "__hwmodes" "g") ]]; then
#	g_sta="${cur_dev}"
#a n
#elif [[ $(list_contains "__hwmodes" "a") ]]; then
#	a_sta="${cur_dev}"
#fi
__dev_master_info(){
	local __tmp
	local __info
	
	eval "__info=\$${1}"
	[ -z "${__info}" ] && return 0
	if [ -z "${3}" ]; then
		__tmp="$(jsonfilter -s "${__info}" -e "${2}=$.hwmodes[($.mode='Master')]")"
	else
		__tmp="$(jsonfilter -s "${__info}" -e "${2}=$.${3}")"
	fi
	[ -z "${__tmp}" ] && \
		unset "${2}" && \
		return 1
	eval "${__tmp}"
}
get_sta_sec() {
	local __tmp
	local __info
	
	eval "__info=\$${1}"
	[ -z "${__info}" ] && return 0
	__tmp=$(jsonfilter -s "${__info}" -e "${2}=$.*.interfaces[@.config.mode='sta'].section")
	[ -z "${__tmp}" ] && \
		unset "${2}" && \
		return 1
	eval "${__tmp}"
}
get_wifi_info() {
local _orig RESP __radios _radio rtype disabled hwmode _ikey _secid _ifname _mode __ret _ret
RESP=$(ubus call network.wireless status)
json_set_namespace "_dev_info" _orig
json_load "${RESP}"
json_get_keys __radios
for _radio in ${__radios}; do
	json_get_type rtype "${_radio}"
	if [ "${rtype}" == "object" ]; then
		json_select "${_radio}"
		json_get_vars disabled "disabled"
		json_select "config"
		json_get_var hwmode "hwmode"
		json_select ..
		json_get_keys __ikeys "interfaces"
		if [ "${__ikeys}" != "" ]; then
			json_select "interfaces"
			for _ikey in ${__ikeys}; do
				json_select "${_ikey}"
				json_get_var _secid "section"
				json_get_var _ifname "ifname"
				json_select "config"
				json_get_var _mode "mode"
				#if [ "${_mode}" == "sta" ]; then
					__ret="\"${_ifname}\": { \"device\":\"${_radio}\", \"hwmode\":\"${hwmode}\", \"disabled\":${disabled}, \"ifname\":\"${_ifname}\", \"section\":\"${_secid}\", \"mode\":\"${_mode}\" }"
					if [ -z "${_ret}" ]; then
						_ret="${__ret}"
					else
						_ret="${_ret}, ${__ret}"
					fi
				#fi
				json_select .. #config
				json_select .. #interfacesx
			done
			json_select .. #interfaces
		fi
	json_select .. #radios
	fi
done
#json_cleanup
#json_load "${_ret}"
#json_dump 2>/dev/null >"${1}"
json_cleanup
json_set_namespace "${_orig}"
eval "${1}='{ ${_ret} }'"
}
#pars_wifi_info <src> <ret> <mode> <option>
pars_wifi_info() {
	local __tmp
	local __info
	
	eval "__info=\$${1}"
	[ -z "${__info}" ] && return 0
	__tmp=$(jsonfilter -s "${__info}" -l 1 -e "${2}=$[@.mode='${3}'].${4}")
	[ -z "${__tmp}" ] && \
		unset "${2}" && \
		return 1
	eval "${__tmp}"
}
#build_trying_list_from_loaded +<ret_var> <config_path> <trying_config> <trying_type> <know_type> <out_config> <ret>
build_trying_list_from_loaded() {
	[ "$#" -eq 7 ] || return 0
	local ret_var=${1}; shift 1
	local config_path=${1}; shift 1
	local trying_config=${1}; shift 1
	local trying_type=${1}; shift 1
	local know_type=${1}; shift 1
	local out_config=${1}; shift 1
	local ret=${1}; shift 1

	local __sections _time
	eval "__sections=\$${ret_var}"
	local scan_json="${out_config}_scan"
	local trying_json="${out_config}_try"

	if [ -z "${__sections}" ] ;then
		write_log 3 "* zero station survey ..."
	else
		local _orig
		json_set_namespace "_trying_" _orig
		json_init
		json_add_array "results"
		config_foreach_specified "${ret_var}" foreach_prepare_station_json "${trying_type}" "${trying_type}" "${trying_config}"  "${know_type}" "${scan_json}" "${config_path}" "${ret}"
		json_close_array
		json_select "results"
		json_dump 2>/dev/null >"${config_path}/${scan_json}"
		json_cleanup
		json_set_namespace "${_orig}"
	fi
}
wifi_fakemac() {
	local ERR_LAST
	local __MAC="${2}"
	which macchanger >&2 &>/dev/null
	ERR_LAST=$?
	if [ ! -z "${__MAC}" ]; then

	local INFO _orig _stasec _hwmode _band
	#mode="Ad-Hoc"/->"adhoc"/bssid_only else "sta", wds, monitor, mesh
	INFO=$(ubus call network.wireless status)
	json_set_namespace "_dev_info" _orig
	json_load "${INFO}"
	#ch->f >2484 == 11a else 11g
	#_band="${hwmode##*[0-9]}"
	local _radio rtype hwmode __ikeys _ikey _mode __ret __dev __ifname __dis __dev_ap
json_get_keys __radios
for _radio in ${__radios}; do
	json_get_type rtype "${_radio}"
	if [ "${rtype}" == "object" ]; then
		json_select "${_radio}"
		json_get_vars disabled "disabled"
		json_select "config"
		json_get_var hwmode "hwmode"
		json_select ..
		json_get_keys __ikeys "interfaces"
		if [ "${__ikeys}" != "" ]; then
			json_select "interfaces"
			for _ikey in ${__ikeys}; do
				json_select "${_ikey}"
				json_get_var _secid "section"
				json_get_var _ifname "ifname"
				json_select "config"
				json_get_var _mode "mode"
				if [ "${_mode}" == "sta" ]; then
					if [ "${band}" == "A" -a "${hwmode}" == "11a" -o "${band}" != "A" -a "${hwmode}" != "11a" ]; then
						__ret="${_secid}"
						__dev="${_radio}"
						__ifname="${_ifname}"
					else
						if [ -z "${__dis}" ]; then
							__dis="${_secid}"
						else
							__dis="${__dis}${IFS}${_secid}"
						fi
					fi
				else
					if [ "${band}" == "A" -a "${hwmode}" == "11a" -o "${band}" != "A" -a "${hwmode}" != "11a" ]; then
						__dev_ap="${_radio}"
					fi
				fi
				json_select .. #config
				json_select .. #interfacesx
			done
			json_select .. #interfaces
		fi
	json_select .. #radios
	fi
done
	json_cleanup
	json_set_namespace "${_orig}"

	[ -z "${__ifname}" ] && return 1
	ubus call network.interface.${1} down
	#ifconfig "${__ifname}" down
		if [ "${__MAC}" == "auto" ]; then
			if [ "${ERR_LAST}" -eq 0 ]; then
				__ret=$(macchanger -r "${__ifname}" 2>"${ERRFILE}")
				ERR_LAST=$?
				[ "${ERR_LAST}" -ne 0 ] && return 2
				__MAC=$(echo "${__ret}" | sed -ne "s/^.?*MAC:[ ]*\([^ ]*\).*$/\1/p")
				[ -z "${__MAC}" ] && return 3
			else
				write_log 3 "* machanger bin not installed, macchange skiped [ ${__MAC} ]"
				return 1
			fi
		else
			macchanger -m "${__MAC}" "${__ifname}" 2>"${ERRFILE}"
			ERR_LAST=$?
			[ "${ERR_LAST}" -ne 0 ] && return 2
		fi
		write_log 3 "* new mac address for ${__ifname} [ ${__MAC} ]"
		uci set network.${1}.macaddr="${__MAC}"
	#ifconfig "${__ifname}" up
	ubus call network.interface.${1} up
	else
		local key=$(uci -q get network.${1}.macaddr)
		[ "$key" != "" ] && uci delete network.${1}.macaddr
	fi
}
# band bssid ssid channel key auth macaddr
#
wifi_configure() {
	local INFO _orig _stasec _hwmode _band
	#mode="Ad-Hoc"/->"adhoc"/bssid_only else "sta", wds, monitor, mesh
	INFO=$(ubus call network.wireless status)
	json_set_namespace "_dev_info" _orig
	json_load "${INFO}"
	#ch->f >2484 == 11a else 11g
	#_band="${hwmode##*[0-9]}"
	local _radio rtype hwmode __ikeys _ikey _mode __ret __dev __ifname __dis __dev_ap
json_get_keys __radios
for _radio in ${__radios}; do
	json_get_type rtype "${_radio}"
	if [ "${rtype}" == "object" ]; then
		json_select "${_radio}"
		json_get_vars disabled "disabled"
		json_select "config"
		json_get_var hwmode "hwmode"
		json_select ..
		json_get_keys __ikeys "interfaces"
		if [ "${__ikeys}" != "" ]; then
			json_select "interfaces"
			for _ikey in ${__ikeys}; do
				json_select "${_ikey}"
				json_get_var _secid "section"
				json_get_var _ifname "ifname"
				json_select "config"
				json_get_var _mode "mode"
				if [ "${_mode}" == "sta" ]; then
					if [ "${band}" == "A" -a "${hwmode}" == "11a" -o "${band}" != "A" -a "${hwmode}" != "11a" ]; then
						__ret="${_secid}"
						__dev="${_radio}"
						__ifname="${_ifname}"
					else
						if [ -z "${__dis}" ]; then
							__dis="${_secid}"
						else
							__dis="${__dis}${IFS}${_secid}"
						fi
					fi
				else
					if [ "${band}" == "A" -a "${hwmode}" == "11a" -o "${band}" != "A" -a "${hwmode}" != "11a" ]; then
						__dev_ap="${_radio}"
					fi
				fi
				json_select .. #config
				json_select .. #interfacesx
			done
			json_select .. #interfaces
		fi
	json_select .. #radios
	fi
done
	json_cleanup
	json_set_namespace "${_orig}"

	#_disabled="1"
	#[ "${band}" == "A" ] || _disabled="0"
	#for _stasec in ${__dis}; do uci set wireless.${_stasec}.disabled="${_disabled}"; done
	for _stasec in ${__dis}; do uci delete wireless.${_stasec}; done

	if [ -z "${__dev}" ]; then
		if [ ! -z "${__dev_ap}" ]; then
			write_log 4 "* no suitable sta mode device build one"
			__ret="atrp_${__dev_ap}_sta"
			new_sec=$(uci add wireless wifi-iface)
			uci rename wireless.${new_sec}="${__ret}"
			# __ret="${new_sec}"
			uci set wireless.${__ret}.device="${__dev_ap}"
			uci set wireless.${__ret}.network="${__IFACE}"
			uci set wireless.${__ret}.mode="sta"
			__dev="${__dev_ap}"
		else
			write_log 2 "* no suitable device to match the select station"
			return
		fi
	fi
	write_log 4 "* sta mode device [ ${__ret}.${__dev} ]"
	_stasec="${__ret}"
	local htmode="HT20"
	#uci set wireless.${__dev}.htmode="${htmode}"
	uci set wireless.${__dev}.channel="${channel}"
	#A
	#htmode
	#HT40
	#HT40+:[36, 44, 52, 60, 100, 108, 116, 124, 132, 140, 149, 157]
	#HT40-:[40, 48, 56, 64, 104, 112, 120, 128, 136, 144, 153, 161]
	#VHT40:[36, 44, 52, 60, 100, 108, 116, 124, 132, 140, 149, 157]
	#VHT80:[36, 52, 100, 116, 132, 149]
	#VHT160:[36, 100]
	#G
	#htmode
	#HT20/VHT20
	local commit=1
	#band bssid ssid channel key auth
	uci set wireless.${_stasec}.encryption="${auth}"
	case "${auth}" in
		"psk"|"psk2")
			uci set wireless.${_stasec}.key="${key}"
			;;
		"wep")
			uci set wireless.${_stasec}.key=1
			uci set wireless.${_stasec}.key1="${key}"
			;;
		"none")
			local key=$(uci -q get wireless.${_stasec}.key)
			[ "$key" != "" ] && uci delete wireless.${_stasec}.key
			;;
		*)
			commit=0
			write_log 2 "* encryption type error [ ${auth} ]"
			;;
	esac
	[ "${commit}" -ne 1 ] && return
	uci set wireless.${_stasec}.disabled="0"
	uci set wireless.${_stasec}.bssid="${bssid}"
	uci set wireless.${_stasec}.ssid="${ssid}"
	wifi
	wifi_fakemac "${__IFACE}" "${macaddr}"
	uci commit wireless
	uci_set_state "network" "${__IFACE}" "up" "0"
	uci_set_state "network" "${__IFACE}" "ipaddr" ""
	uci_set_state "network" "${__IFACE}" "gateway" ""
	uci_set_state "network" "${__IFACE}" "ifname" ""
	/etc/init.d/network restart 2>/dev/null
}
dhcp_recheck() {
	[ -f /etc/config/dhcp.fs ] || cat /etc/config/dhcp > /etc/config/dhcp.fs
	if ! uci -q show dhcp.@dnsmasq[0] >/dev/null; then
		cat /etc/config/dhcp.fs > /etc/config/dhcp
		/etc/init.d/dnsmasq reload
		write_log 3 "DHCP failsafe mode."
	fi
}
#trying_association <config_path> <out_config> <ret>
trying_association() {
	local config_path="${1}"; shift 1
	local out_config=${1}; shift 1
	local ret=${1}; shift 1

	local DATA=""
	local _orig
	local ASSOCIATED=0
	local scan_json="${out_config}_scan"
	local trying_json="${out_config}_try"

	json_set_namespace "_association_" _orig
	#json_init
	DATA="$(cat ${config_path}/${scan_json})"
	json_load "${DATA}"
	local _key keys band bssid ssid channel key auth is_mac dev_str percent section
	json_select "results"
	json_get_keys keys
	if [ ! -z "${keys}" ] ;then
		write_log 6 "* preparing    ...[ ${keys} ]"
		for _key in $keys; do
			json_select ${_key}
			json_get_vars band bssid ssid channel key auth is_mac dev_str percent section macaddr
			_time=$(eval "${DATE_PROG}")
			json_add_string "trying" "${_time}"
			json_select ..
			json_select ..
			json_dump 2>/dev/null >"${config_path}/${trying_json}"

			eval "${ret}=\"\$((\$${ret} + 1))\""
			eval "write_log 5 \"* configuring  ...[ \$${ret} ${percent}% - ${dev_str} ]\""
			wifi_configure
			write_log 6 "* ifup waiting ...[ ${dhcp_timeout}s ]"
			dhcp_recheck
			local i=${dhcp_timeout}
			local _ipv4 _ipgw
			while [ "${i}" -gt 0 ]; do
				#if [ "$(uci_get_state "network" "${__IFACE}" "up" "0")" -eq 1 ]; then
				network_flush_cache
				if [ network_is_up ]; then
					network_get_ipaddr _ipv4 ${__IFACE} 
					network_get_gateway _ipgw ${__IFACE}
					[ "${_ipv4}" = "0.0.0.0" -o "${_ipgw}" = "0.0.0.0" -o -z "${_ipv4}" -o -z "${_ipgw}" ] || break
				fi
				i=`expr ${i} - 1`
				sleep 1
			done

			pingout PING_OUT 1
			if [ ${PING_OUT} -eq 0 ] ;then
				#update dev_str state
				update_secs_status "${section}" "LastConn" "ok" "$(eval ${DATE_PROG})"
				ASSOCIATED=1
			else
				update_secs_status "${section}" "LastConn" "fail" "$(eval ${DATE_PROG})"
				write_log 2 "* ping failed in association testing"
			fi
			DATA="$(cat ${config_path}/${trying_json})"
			json_load "${DATA}"
			json_select "results"
			[ "${ASSOCIATED}" -ne 0 ] && break			
		done
	fi
	json_cleanup
	unset DATA
	json_set_namespace "${_orig}"
	return ${ASSOCIATED}
}
#site_survey_ubus outfile 2>/dev/null
site_survey_ubus() {
	[ -z "${1}" ] && return 0
	local  DEVS INFO RESULT _time _orig _last cur_dev cur_devs __key __keys _drop quality quality_max percent channel
	local _counter=0

	if ubus list iwinfo >/dev/null 2>/dev/null; then
		local DEVS=$(ubus call iwinfo devices '{}')
		#clean data file
		rm -rf "${DATFILE}"
		rm -rf "${ERRFILE}"
		json_set_namespace "_devs" _orig
		#call on json_load self
		#json_init
		json_load "${DEVS}"
		json_select "devices"
		json_get_values cur_devs
		# loop through the dkeys
		for cur_dev in $cur_devs; do
			INFO=$(eval ubus call iwinfo info '{\"device\":\"${cur_dev}\"}')
			json_set_namespace "_info" _last
			json_load "${INFO}"
			json_get_var _mode "mode"
			if [ "${_mode}" == "Master" ] ;then
				RESULT=$(eval ubus call iwinfo scan '{\"device\":\"${cur_dev}\"}')
				if [ ! -z "${RESULT}" ]; then
					_time=$(eval "${DATE_PROG}")
					json_set_namespace "_results"
					json_load "${RESULT}"
					json_select "results"
					json_get_keys __keys
					if [ "${__keys}" != "" ]; then
						for __key in ${__keys}; do
							json_select "${__key}"
							json_get_vars quality quality_max channel
							if [ "${quality}" -eq 0 ]; then
								percent=0
							else
								percent=$(echo "${quality}" "${quality_max}" | awk -e '{printf "%d", 100 / $2 * $1}')
								[ "${percent}" -gt 100 ] && percent=100
							fi
							json_add_string "percent" "${percent}"
							if [ "${channel}" -gt 30 ]; then
								json_add_string "band" "A"
							else
								json_add_string "band" "G"
							fi
							json_add_string "seen" "${_time}"
							json_select ..
						done
						json_select ..
						RESULT=$(json_dump)
					fi
					jsonfilter -s "${RESULT}" -e "$.results.*" -p 2>/dev/null >>"${DATFILE}"
					write_log 7 "* station scanning result [ ${cur_dev} ]\n$(cat ${DATFILE})"
					json_cleanup
					json_set_namespace "_info"
				fi
			fi
			json_cleanup
			json_set_namespace ${_last}
		done

		json_cleanup
		json_set_namespace "_results"
		#rebuild results json structure
		_counter=$(cat "${DATFILE}" | wc -l )
		#resort by signal strength and deal A band
		if [ "${a_band_first}" -ne 0 ] ;then
			RESULT=$(awk -v mp="${scanpercent}" -e '{percent=gensub(/^.*\"percent\":[^0-9]*?([0-9]+).*$/, "\\1", "g", $0); if(percent <= mp) next; band=gensub(/^.*\"band\":[ ]*?\"(.).*$/, "\\1", "g", $0); _bo= band == "A" ? 1 : 0 ; printf "%d%03d %s\n" , _bo, percent, $0}' "${DATFILE}" | sort -nr | sed 's/^[^ ]* //')
		else
			RESULT=$(awk -v mp="${scanpercent}" -e '{percent=gensub(/^.*\"percent\":[^0-9]*?([0-9]+).*$/, "\\1", "g", $0); if(percent <= mp) next; print percent, $0}' "${DATFILE}" | sort -nr | sed 's/^[^ ]* //')
		fi
		#no new lines
		#RESULT=$(echo "${RESULT}" | awk -e 'NR==1 {printf "{ \"results\": [ %s", $0} NR>=1 {printf ", %s", $0} END {printf " ] }"}')
		#normal
		RESULT=$(echo "${RESULT}" | awk -e 'NR==1 {print "{ \"results\": [ ", $0} NR>=1 {print ",", $0} END {print " ] }"}')
		#filter out weak stations
		#jsonfilter -s "${RESULT}" -e "$.results[@.percent>='${scanpercent}']"
		echo "${RESULT}" >"${1}"
		json_cleanup
		json_set_namespace ${_orig}
	else
		write_log 12 "* calling 'rpcd-mod-iwinfo package not installed!!"
	fi
	write_log 6 "* site survey returns available [ ${_counter} ]"
	return ${_counter}
}
#site_survey file 2>/dev/null
site_survey () {
	[ -z "${1}" ] && return 0
	local _counter=0
	#/sbin/wifi
	#/www/js/basic.js/scannedSsids/parseWifiScan
	#function parseWifiScan(rawScanOutput)
	#
	if [ -e "/lib/wifi/broadcom.sh" ] ; then
		scan_brcm 2>/dev/null >"${DATFILE}"
	elif [ -e "/lib/wifi/mac80211.sh" ] ; then
		scan_mac80211 2>/dev/null >"${DATFILE}"
	elif [ -e "/lib/wifi/madwifi.sh" ] ; then
		scan_madwifi 2>/dev/null >"${DATFILE}"
	fi
	local _time=$(eval "${DATE_PROG}")
###############################################################
#Cell 01 - Address: xx:xx:xx:xx:xx:xx
#          ESSID: "TP-LINK_"
#          Mode: Master  Channel: 6
#          Signal: -68 dBm  Quality: 42/70
#          Encryption: mixed WPA/WPA2 PSK (CCMP)
###############################################################
	#parsing use awk
	cat "${DATFILE}" | awk -v abandfirst="${a_band_first}" -v minipercent="${scanpercent}" -v time_stamp="${_time}" -f /usr/lib/autorepeater/scan_mac80211.awk >"${1}" 2>"${ERRFILE}"
	_counter=$?
	write_log 2 "* site survey returns available [ ${_counter} ]"
	return ${_counter}
}
#pingout var retry_once
pingout() {
	local __FAIL=1
	[ $# -gt 2 ] && write_log 3 "Error calling 'pingout()' - wrong number of parameters"
	#write_log 6 "* internet state checking..."
	#ubus call
	network_flush_cache
	network_get_gateway ROUTER_IP ${__IFACE} >&2 &>"${ERRFILE}"
	# Try pinging only if a ipaddress was assigned
	local _ping_stat=""
	if [ -n "${ROUTER_IP}" -a "${ROUTER_IP}" != "0.0.0.0" ]; then
		_ping_stat="$(ping -c4 -w5 "${ping_host}" 2>"${ERRFILE}" | grep [/,] | sed 'N;s/.*,//; s/\n/. Ping /')"
		[ -z "${_ping_stat}" -a -n "${2}" ] && _ping_stat=$(ping -c4 -w5 "${ping_host}" | grep [/,] | sed 'N;s/.*,//; s/\n/. Ping /')
		if [ ! -z "${_ping_stat}" ]; then
			__FAIL=0
			write_log 6 "* ping returns: \"${_ping_stat}\""
		else
			write_log 7 "#> eval ping -c4 -w5 \"${ping_host}\" | grep [/,] | sed 'N;s/.*,//; s/\n/. Ping /'\n$(cat ${ERRFILE})"
		fi
	else
		write_log 3 "* no ipaddress was assigned to interface [ ${__IFACE} ]\n$(cat ${ERRFILE})"
	fi
# Defines the GPIO for showing that a connection was established.
# The GPIO number to use is different for each router.
# Check the GPIO layout of your router in the Wiki or in the forum.
# Make sure the GPIO you select is not used by a SD/MMC modification.
#[ -n "${_ping_stat}" ] && gpio disable ${established_gpio} || gpio enable ${established_gpio}
	eval "$1=\"$__FAIL\""
}
#portmapping_trying <_section_type> <_section> <_option>
portmapping_trying() {
	[ $# -eq 3 ] || return 0
	local _section_type=${1}; shift 1
	local _section=${1}; shift 1
	local _option=${1}; shift 1
	local ERR_LAST PNPDSTATE SSDP_URL
	
	local len=0
	if [ "$upnpc_enabled" == "1" ]; then
		which upnpc >&2 &>/dev/null
		ERR_LAST=$?
		[ "${ERR_LAST}" -gt 0 ] && write_log 0 "* UPnP binary:\"upnpc\" not detected, WAN port mapping skiped!" && return ${ERR_LAST}
		#uci -P/var/state get network.wan.ipaddr|gateway
		#network.sh network_get_ipaddr|gateway
		#ubus call
		network_flush_cache
		network_get_gateway ROUTER_IP ${__IFACE}
		PNPDSTATE=1
		SSDP_URL=""
		
		#config_get len "${_section}" "${_option}_LENGTH"
		#write_log 6 "* UPnP IGD root_url.length [ ${len} ]"
		config_list_foreach_once_atleast "${_section_type}" "${_section}" "${_option}" pnp_ssdp
		if [ "${PNPDSTATE}" -eq 0 ] ;then
			write_log 5 "* UPnP IGD device founded [ ${_option}=\"${SSDP_URL:=UPDATE_ROOT_URL_FETHING_SCRIPT_PLEASE}\" ]"
			config_foreach port_mapping "${_section_type}" "${_section_type}"
		else
			write_log 3 "* UPnP IGD device descovery failed [ ${ROUTER_IP} ]"
		fi
	else
		write_log 5 "* UPnP port mapping disabled by settings"
	fi
}
#pnp_ssdp [root_url]
pnp_ssdp() {
	local _para=""

	[ ${PNPDSTATE} -eq 0 ] && return 0
	SSDP_URL=$(echo "${1}" | sed -e "s#\[ROUTERIP\]#${ROUTER_IP}#g")
	if [ -z "${SSDP_URL}" ]; then
		if [ "${upnpc_forceroot}" == "1" ]; then
			write_log 6 "* UPnP IGD device descovery process disabled by settings"
			return 0
		else
			write_log 6 "* UPnP IGD device descovery process..."
		fi
	else
		write_log 6 "* UPnP IGD url trying     [ root_url=\"${SSDP_URL}\" ]"
		_para="-u \"${SSDP_URL}\""
	fi
	eval "upnpc ${_para} -s 2>\"${ERRFILE}\" >\"${DATFILE}\""
	PNPDSTATE=$?
	if [ -z "${SSDP_URL}" ]; then
		[ "${PNPDSTATE}" -eq 0 ] || write_log 7 "#> eval \"upnpc ${_para} -s 2>\"${ERRFILE}\" >\"${DATFILE}\"\"\n$(cat ${DATFILE})"
		SSDP_URL=$(grep "desc:" "${DATFILE}" | sed -ne "s/.*desc:[ /t]*\(http[^ ]*\)/\1/p")
	fi
	return ${PNPDSTATE}
}
#port_mapping <section_id> <check_type>
port_mapping() {
	local ERR_LAST
	#set defaults for not set value
	ATRP_upnp_enabled="0"
	reload_all_config_from_mem "${1}" "${2}" "ATRP_upnp_"
	ERR_LAST=$?
	if [ "${ERR_LAST}" -ne 0 ] ;then
		write_log 3 "* reloading error on configured pnpmap info retrive [ ${ERR_LAST}/${section_id}.TYPE!=${check_type} ]"
		return ${ERR_LAST}
	fi

	if [ "${ATRP_upnp_enabled}" == "1" ] ;then
		write_log 6 "* UPnP port map trying       [ ${1}:${ATRP_upnp_port} \"${ATRP_upnp_proto}\" ]"
		ERR_LAST=1
		local _ut=0
		while [ ${ERR_LAST} -ne 0 -a $_ut -lt ${upnpc_failsafe} ]; do
			eval "upnpc -u \"${SSDP_URL}\" -d \"${ATRP_upnp_port}\" \"${ATRP_upnp_proto}\" 2>\"${ERRFILE}\" >\"${DATFILE}\""
			eval "upnpc -u \"${SSDP_URL}\" -e \"${ATRP_upnp_des}\" -r \"${ATRP_upnp_port}\" \"${ATRP_upnp_proto}\" 2>>\"${ERRFILE}\" >\"${DATFILE}\""
			ERR_LAST=$?
			_ut=$(($_ut+1))
		done
		if [ ${ERR_LAST} -eq 0 ] ;then
			update_secs_status "${1}" "LastMap" "ok" "$(eval ${DATE_PROG})"
			#write_log 6 "* UPnP port mapping sucessfully [ ${_ut}/${upnpc_failsafe} ]"
			#write_log 7 "#> eval \"upnpc -u \"${SSDP_URL}\" -e \"${ATRP_upnp_des}\" -r \"${ATRP_upnp_port}\" \"${ATRP_upnp_proto}\" 2>>\"${ERRFILE}\" >\"${DATFILE}\"\"\n$(cat ${DATFILE})"
			write_log 7 "#> $(cat ${DATFILE} | grep external)"
		else
			update_secs_status "${1}" "LastMap" "fail" "$(eval ${DATE_PROG})"
			write_log 5 "* UPnP port mapping failed [ ${_ut}/${upnpc_failsafe} ]"
			write_log 7 "#> eval \"upnpc -u \"${SSDP_URL}\" -e \"${ATRP_upnp_des}\" -r \"${ATRP_upnp_port}\" \"${ATRP_upnp_proto}\" 2>>\"${ERRFILE}\" >\"${DATFILE}\"\"\n$(cat ${ERRFILE})"
		fi
	else
		write_log 4 "* UPnP port mapping disabled [ ${1}:${ATRP_upnp_port} \"${ATRP_upnp_proto}\" ]"
	fi
}
#reload_all_config_from_mem <section> <type_checking> [var_prefix:-ATRP_]
#returns:
#noset 1
#type checking fail 2
reload_all_config_from_mem()
{
	[ "$#" -ge 2 ] || return 0
	local __SECTIONID="${1}"; shift
	local __TYPE="${1}"; shift
	local __ATRP="${1:-ATRP_}"; shift
	local __VAR
	local __ALL_OPTION_VARIABLES=""
	local cfgtype
	#config type checking
	#CONFIG_cfg028243_TYPE='wifi-scan'
	#CONFIG_cfg028243_ssid='TP-LINK_'
	config_get cfgtype "${__SECTIONID}" TYPE
	[ "${cfgtype}"x == "${__TYPE}"x ] || return ${ERROR_MEM_TYPE}
	#`set -o posix;set`maybe more clean
	__ALL_OPTION_VARIABLES=$(eval "set | sed -ne 's/^CONFIG_${__SECTIONID}_\(.*\)=.*$/\1/p' | grep -v \"^TYPE$\"" )
	[ -z "$__ALL_OPTION_VARIABLES" ] && return ${ERROR_MEM_EMPTY}
	for __VAR in $__ALL_OPTION_VARIABLES
	do
		eval export ${NO_EXPORT:+-n} ${__ATRP}${__VAR}=\"\${CONFIG_${__SECTIONID}_${__VAR}}\"
	done
	return 0
}
#match_section_by_loaded <ret> <known_section_id> <know_type> <scan_section_id> <scan_type>
match_section_by_loaded() {
	[ "$#" -eq 5 ] || return 7
	local ret="${1}"; shift
	local known_section_id="${1}"; shift
	local know_type="${1}"; shift
	local scan_section_id="${1}"; shift
	local scan_type="${1}"; shift

	#set defaults for not set value
	ATRP_known_enabled="0"
	reload_all_config_from_mem "${known_section_id}" "${know_type}" "ATRP_known_"
	ERR_LAST=$?
	eval "${ret}=\"${known_section_id}\""
	[ "${ERR_LAST}" -ne 0 ] && return ${ERR_LAST}

	__cmpstr="${ATRP_scaned_ssid}"
	[ "${ATRP_known_is_mac}" -eq 1 ] && __cmpstr="${ATRP_scaned_bssid}"
	ERR_LAST=7
	eval "${ret}=\"${ATRP_scaned_bssid} ${ATRP_scaned_percent}% - ${ATRP_scaned_ssid}\""

	#may recheck the comparision
	[ "x${ATRP_known_dev_str}" == "x${__cmpstr}" ] && ERR_LAST=0
	
	if [ "${ERR_LAST}" -eq 0 ]; then
		update_secs_status "${known_section_id}" "LastSignal" "bssid" "${ATRP_scaned_bssid}"
		update_secs_status "${known_section_id}" "LastSignal" "signal" "$(eval ${DATE_PROG}) - ${ATRP_scaned_percent}"
		update_secs_status "${known_section_id}" "Realcipher" "encryption" "${ATRP_scaned_encryption}"
		eval "${ret}=\"${ATRP_known_dev_str}\""
		if [ "${ATRP_known_enabled}" != "1" ] ;then
			eval "${ret}=\"  ${ATRP_scaned_percent}% - ${known_section_id}.${ATRP_known_dev_str}\""
			ERR_LAST=${WARN_DISABLED_KNOWN}
		elif [ "${minipercent}" -gt "${ATRP_scaned_percent}" ]; then
			eval "${ret}=\"${known_section_id}.${ATRP_known_dev_str} ${ATRP_scaned_percent}%\""
			ERR_LAST=${WARN_WEAK_KNOWN}
		fi
	else
		if [ "${minipercent}" -gt "${ATRP_scaned_percent}" ]; then
			ERR_LAST=${NOT_MATCH_WEAK}
		else
			ERR_LAST=${NOT_MATCH_HEALTH}
		fi
	fi
	return ${ERR_LAST}
}
#foreach_prepare_new_config_from_loaded <scan_section_id> <scan_type> <scan_config> <know_type> <ret>
foreach_prepare_new_config_from_loaded() {
	[ "$#" -eq 5 ] || return 0
	local scan_section_id=${1}; shift 1
	local scan_type=${1}; shift 1
	local scan_config=${1}; shift 1
	local know_type=${1}; shift 1
	local ret=${1}; shift 1

	local cfgtype=""
	local ___function="match_section_by_loaded"

	local trying_section=""
	local ___ret=${ERROR_NO_CATCH}
	local ___lret=${ERROR_NO_CATCH}
	local __dev_info=""
	local __ldev_info=""

	[ -z "${CONFIG_SECTIONS}" ] && return 0
	#reverse scan direction
	local sep=${LIST_SEP:-" "}
	local __s __rev _counter
	for __s in ${CONFIG_SECTIONS}; do __rev="${__rev:+${__rev}}${__s:+${sep}}${__s}"; done

	local __cmpstr
	reload_all_config_from_mem "${scan_section_id}" "${scan_type}" "ATRP_scaned_"
	ERR_LAST=$?
	if [ "${ERR_LAST}" -eq 0 ] ;then
		for known_section_id in ${__rev}; do
				trying_section="${known_section_id}_trying"
				config_get cfgtype "${known_section_id}" TYPE
				[ -n "${know_type}" -a "x$cfgtype" != "x${know_type}" ] && continue
				eval "${___function} __ldev_info \"\${known_section_id}\" \"\${know_type}\" \"\${scan_section_id}\" \"\${scan_type}\""
				___lret=$?
				if [ ${___lret} -lt ${___ret} ]; then
					___ret=${___lret}
					__dev_info="${__ldev_info}"
					[ ${___ret} -lt ${NOT_MATCH_WEAK} ] && break
				fi
		done
	else
		___ret="${ERR_LAST}"
		__dev_info="${scan_section_id}"
	fi
	case "${___ret}" in
		0)
			eval "${ret}=\"\$((\$${ret} + 1))\""
			eval "_counter=\$${ret}"
			write_log 1 "+ matched  [ ${_counter} ${ATRP_scaned_percent}% - ${known_section_id}.${__dev_info} ]"
			#write_log 1 "${UCI_CONFIG_DIR} - ${scan_config}.${scan_section_id} - ${trying_section}"
			[ -z "${__dev_info}" ] && write_log 1 "funny, we get a empty dev_str"
			uci_rename "${scan_config}" "${scan_section_id}" "${trying_section}" 2> "${ERRFILE}"
			ERR_LAST=$?
			if [ "${ERR_LAST}" -ne 0 ]; then
				write_log 3 "* uci command returns [ ${ERR_LAST} ]\n $(cat ${ERRFILE})"
			fi
			uci_set "${scan_config}" "${trying_section}" "dev_str" "${__dev_info}"
			uci_set "${scan_config}" "${trying_section}" "matching" "$(eval ${DATE_PROG})"
			#set the position to button 2^31-1(32bit) /=0 for top
			/sbin/uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} reorder "${scan_config}.${trying_section}=2147483647"
			;;
		${ERROR_MEM_EMPTY})
			write_log 3 "* section error [ ${__dev_info} ]"
			uci_remove "${scan_config}" "${scan_section_id}"
			;;
		${WARN_DISABLED_KNOWN})
			write_log 4 "- disabled [ ${__dev_info} ]"
			uci_remove "${scan_config}" "${scan_section_id}"
			;;
		${WARN_WEAK_KNOWN})
			write_log 5 "- weaknown [ ${__dev_info} ]"
			uci_remove "${scan_config}" "${scan_section_id}"
			;;
		${NOT_MATCH_WEAK})
			write_log 6 "- weak     [ ${__dev_info} ]"
			uci_remove "${scan_config}" "${scan_section_id}"
			;;
		${NOT_MATCH_HEALTH})
			write_log 6 "- unknown  [ ${__dev_info} ]"
			uci_remove "${scan_config}" "${scan_section_id}"
			;;
#		${ERROR_NO_CATCH})
#			;;
		*)
			write_log 7 "* unknown error on #> ${___function} __ldev_info \"${known_section_id}\" \"${know_type}\" \"${scan_section_id}\" \"${scan_type}\""
			return 1
			;;
	esac
	return ${___lret}
}
#dump_available_station_from_loaded +<ret_var> <cfg_path> <scan_config> <scan_type> <know_type> <out_config> <ret>
#reserved +<ret_var> <config>
dump_available_station_from_loaded() {
	[ "$#" -eq 7 ] || return 0
	local ret_var=${1}; shift 1
	local cfg_path=${1}; shift 1
	local scan_config=${1}; shift 1
	local scan_type=${1}; shift 1
	local know_type=${1}; shift 1
	local out_config=${1}; shift 1
	local ret=${1}; shift 1

	local __sections __matched
	eval "__sections=\$${ret_var}"

	if [ -z "${__sections}" ] ;then
		write_log 2 "* wifi scan returns zero station, may change your signal strength filter settings [ $@ ]"
	else
		#first scan_type will shift out by foreach loop
		config_foreach_specified "${ret_var}" foreach_prepare_new_config_from_loaded "${scan_type}" "${scan_type}" "${scan_config}" "${know_type}" "${ret}"
		eval "__matched=\$${ret}"
		if [ "${__matched}" -gt 0 ]; then
			#write_log 7 "* changes dumping to new package [ ${UCI_CONFIG_DIR}/${out_config} ] ...\n$(uci -c${UCI_CONFIG_DIR} changes ${scan_config})"
			write_log 7 "* changes dumping to new package    [ ${UCI_CONFIG_DIR}/${out_config} ]"
			#a trick to build new package
			cd "${UCI_CONFIG_DIR}"
			cp -a "${scan_config}" "${DATFILE}"
			uci_commit "${scan_config}" 2> "${ERRFILE}"
			ERR_LAST=$?
			if [ "${ERR_LAST}" -ne 0 ]; then
				write_log 3 "* uci command returns [ ${ERR_LAST} ]\n $(cat ${ERRFILE})"
			fi
			mv -f "${scan_config}" "${out_config}"
			cp -a "${DATFILE}" "${scan_config}"
		else
			write_log 4 "* zero matched station"
			rm -f "${out_config}"
		fi
	fi
	return 0
}
#foreach_prepare_station_json +<trying_section> <trying_type> <trying_config> <know_type> <json_name> <config_path> <ret>
#atrp section=${trying_section%%_trying}
foreach_prepare_station_json() {
	[ "$#" -eq 7 ] || return 0
	local trying_section=${1}; shift 1
	local trying_type=${1}; shift 1
	local trying_config=${1}; shift 1
	local know_type=${1}; shift 1
	local json_name=${1}; shift 1
	local config_path=${1}; shift 1
	local ret=${1}; shift 1

	local atrp_section=${trying_section%%_trying}
	if [ -z "${atrp_section}" ] ;then
		write_log 3 "* funny, the section cannot to resoled correctly [ ${trying_section} ]"
		return 1
	fi

	#set defaults for not set value
	ATRP_known_enabled="0"
	reload_all_config_from_mem "${atrp_section}" "${know_type}" "ATRP_known_"
	ERR_LAST=$?
	if [ "${ERR_LAST}" -ne 0 ] ;then
		write_log 3 "* reloading error on configured station info retrive [ ${ERR_LAST}/${atrp_section}.TYPE!=${know_type} ]"
		return ${ERR_LAST}
	fi

	reload_all_config_from_mem "${trying_section}" "${trying_type}" "ATRP_trying_"
	ERR_LAST=$?
	if [ "${ERR_LAST}" -ne 0 ] ;then
		write_log 3 "* reloading error on association trying info retrive [ ${ERR_LAST}/${trying_section}.${trying_type} ]"
		return ${ERR_LAST}
	fi

	local _boolean _ver _array _ci
	set -f
	eval "${ret}=\"\$((\$${ret} + 1))\""
	json_add_object "${atrp_section}"
		json_add_string "dev_str" "${ATRP_trying_dev_str}"
		if [ "${ATRP_known_is_mac}" -eq 1 ]; then
			_boolean="1"
		else
			_boolean="0"
		fi
		json_add_string "section" "${atrp_section}"
		json_add_boolean "is_mac" "${_boolean}"
		json_add_string "key" "${ATRP_known_key}"
		json_add_string "macaddr" "${ATRP_known_macaddr}"
		json_add_string "encryption_know" "${ATRP_known_encryption}"
		json_add_string "encryption_scan" "${ATRP_trying_encryption}"
		for _key in "ssid" "bssid" "seen" "mode" "channel" "signal" "quality" "quality_max" "band" "percent" ;do
			eval "json_add_string \"${_key}\" \"\${ATRP_trying_${_key}}\""
		done
		json_add_object "encryption"
			case "${ATRP_trying_enc}" in
			"none" )
				json_add_boolean "enabled" "0"
				_enc="none"
				;;
			* )
			#psk2/psk/wep
				json_add_boolean "enabled" "1"
				_enc="error"
				if [ "${ATRP_trying_wpa}" -ne 0 ]; then
					_enc="wpa"
				elif [ "${ATRP_trying_wep}" -ne 0 ];then
					_enc="wep"
				fi
				json_add_array "${_enc}"
					eval "_ver=\"\${ATRP_trying_${_enc}}\"" ###*[^0-9]
					_ver="${_ver:=1}"
					[ "${_ver}" -gt 1 ] && json_add_int "" "1"
					[ "${_ver}" -gt 2 ] && json_add_int "" "2"
					json_add_int "" "${_ver}"
				json_close_array
				json_add_array "authentication"
					json_add_string "" "${ATRP_trying_enc}" #%%[0-9]*
				json_close_array
				json_add_array "ciphers"
					_array="${ATRP_trying_ciphers//,/ }"
					for _ci in ${_array}; do json_add_string "" "${_ci}"; done
				json_close_array
				;;
			esac
		json_close_object #ends encryption
		if [ "${ATRP_known_encryption}" == "auto" ]; then
			json_add_string "auth" "${ATRP_trying_enc}"
		else
			json_add_string "auth" "${ATRP_known_encryption}"
		fi
	json_close_object #-ends keys
}
#append_diff_ucipath_cfg_and_run <function> <sort_first> <restore_cfg> <cfg_path> <config> [...]
#reserved +<ret_var> <config>
append_diff_ucipath_cfg_and_run() {
	[ "$#" -ge 6 ] || return 0
	local __function=${1}; shift 1
	local __sorttype=${1}; shift 1
	local __restore_cfg=${1}; shift 1
	local __cfg_path=${1}
	#reserved for calling
	local __config=${2}

	#keep touched section changes in mem
	local UCI_CONFIG_DIR=${UCI_CONFIG_DIR}
	#sections
	local CONFIG_SECTIONS=${CONFIG_SECTIONS}
	#sectins counter
	local CONFIG_NUM_SECTIONS=${CONFIG_NUM_SECTIONS}
	#current section
	local CONFIG_SECTION=${CONFIG_SECTION}

	#set appending mode to no
	local CONFIG_APPEND=''
	#if not set appending mode, lists will cleared so save it before uci_load
	local _U_CONFIG_LIST_STATE=${CONFIG_LIST_STATE}
	for VAR in $CONFIG_LIST_STATE; do
	eval "local _U_CONFIG_${VAR}=\$CONFIG_${VAR}"
	eval "local _U_CONFIG_${VAR}_LENGTH=\$CONFIG_${VAR}_LENGTH"
	done

	local _U_UCDIR=${UCI_CONFIG_DIR}
	local _U_SECS=${CONFIG_SECTIONS}
	local _U_SEC=${CONFIG_SECTION}
	local _U_NUM=${CONFIG_NUM_SECTIONS}

	#load scaned result merg to shell mem, lib may change this var name.
	#config default path change to LOGDIR
	write_log 4 "* uci default config path changed:  [ ${__cfg_path} ]"
	UCI_CONFIG_DIR="${__cfg_path}"
	config_load "${__config}"
	#update state
	#uci_set_state "scannow" "section" ""

	#get loaded section list
	local NOW_SECS=${CONFIG_SECTIONS}
	local NOW_SEC=${CONFIG_SECTION}
	local NOW_NUM=${CONFIG_NUM_SECTIONS}
	
	#or reload it simply if no change happen to it
	#uci_load(${__restore_cfg})

	#restore known sections
	CONFIG_SECTIONS=${_U_SECS}
	CONFIG_SECTION=${_U_SEC}
	CONFIG_NUM_SECTIONS=${_U_NUM}
	#restore overwrited known lists
	CONFIG_LIST_STATE=${_U_CONFIG_LIST_STATE}
	for VAR in $_U_CONFIG_LIST_STATE; do
	eval "CONFIG_${VAR}=\$_U_CONFIG_${VAR}"
	eval "CONFIG_${VAR}_LENGTH=\$_U_CONFIG_${VAR}_LENGTH"
	done

	case "${__sorttype}" in
		"1")
			#reorder by known station list
			NOW_SECS="$(awk 'BEGIN{split(ARGV[1], known);for(i in known) {split(ARGV[2], scan); _regex=sprintf(ARGV[3], known[i]); for(j in scan) if(match(scan[j], _regex)) print scan[j]}}' "${CONFIG_SECTIONS}" "${NOW_SECS}" "^%s_trying$")"
			;;
		"3")
			#reorder by signal strength for defaults
			NOW_SECS="$(awk 'BEGIN{split(ARGV[1], stamps);for(i in stamps) {print stamps[i]} }' "${NOW_SECS}" | sort -nr)"
			#undefined asort function
			#NOW_SECS="$(awk 'BEGIN{split(ARGV[1], stamps); outs=asort(stamps); for(i in outs) {print outs[i]} }' "${NOW_SECS}")"
			;;
		*)
	esac

	local __ret_var=${NOW_SECS}
	eval "${__function} \"__ret_var\" \"\$@\""

	#restore loaded section states
	write_log 4 "* uci default config path restored: [ ${_U_UCDIR} ]"
	UCI_CONFIG_DIR=${_U_UCDIR}
	[ -z "${_U_UCDIR}" ] && unset UCI_CONFIG_DIR
	return 0
}
load_all_config_options()
{
	local __PKGNAME="$1"
	local __SECTIONID="$2"
	local __VAR
	local __ALL_OPTION_VARIABLES=""
	config_cb()
	{
		if [ ."$2" = ."$__SECTIONID" ]; then
			option_cb()
			{
				__ALL_OPTION_VARIABLES="$__ALL_OPTION_VARIABLES $1"
			}
		else
			option_cb() { return 0; }
		fi
	}
	config_load "$__PKGNAME"
	[ -z "$__ALL_OPTION_VARIABLES" ] && return 1
	for __VAR in $__ALL_OPTION_VARIABLES
	do
		config_get "$__VAR" "$__SECTIONID" "$__VAR"
	done
	reset_cb
	return 0
}
config_get_first_list_val() {
	[ "$#" -ge 3 ] || return 0
	local __VAR="$1"; shift
	local __SECTIONID="$1"; shift
	local __OPTION="$1"; shift
	#tofix: lib may changed to a var name differ from _ITEM for list items
	config_get "${__VAR}" "${__SECTIONID}" "${__OPTION}_ITEM1"
	return 0
}
load_all_service_sections() {
	local __DATA=""
	config_cb()
	{
		[ "$1" = "autorepeater" ] && __DATA="$__DATA $2"
	}
	config_load "autorepeater"
	eval "$1=\"$__DATA\""
	reset_cb
	return
}
#change_type in mem
#change_type <section> <new_type>
change_type() {
        eval export ${NO_EXPORT:+-n} CONFIG_${1}_TYPE='${2}'
}
#config_foreach_specified <source sections> <function> <c_type> [...]
config_foreach_specified() {
	[ "$#" -gt 3 ] || return 0
	local __sections
	eval "__sections=\$${1}"; shift 1
	local ___function="${1}"; shift 1
	#reserve type parameter not shift by config_foreach
	local ___type="${1}"; shift 1
	local ___ret=1

	[ -z "${__sections}" ] && return 0

	for section in ${__sections}; do
			config_get cfgtype "$section" TYPE
			[ -n "$___type" -a "x$cfgtype" != "x$___type" ] && continue
			eval "$___function \"\$section\" \"\$@\""
			___ret=$?
			[ ${___ret} -ge ${ERROR_NO_CATCH} ] && return ${___ret}
	done
}
#config_list_foreach_once_atleast <____type> <____section> <____option>
config_list_foreach_once_atleast() {
	[ "$#" -ge 4 ] || return 0
	local ____type="$1"; shift
	local ____section="$1"; shift 1
	local ____option="$1"; shift 1
	local ____function="$1"; shift 1
	local ____len
	#tofix: lib may changed to a var name differ from _LENGTH for list length
	config_get ____len "${____section}" "${____option}_LENGTH" "1"
	[ "${____len}" == "1" ] && eval "${____function} \"\$@\""
	[ "${____type}" == "autorepeater" -a "${____len}" == "1" ] && return 0
	#echo "#> eval config_list_foreach \"${____section}\" \"${____option}\" \"${____function}\" \"$@\""
	#eval "echo list.length: \$CONFIG_${____section}_${____option}_LENGTH"
	#set | grep "^CONFIG_global_root_url"
	eval "config_list_foreach \"${____section}\" \"${____option}\" \"${____function}\" \"\$@\""
}
start_autorepeater_interface(){
	logger "Start AutoRepeater daemon [ ${1:-global} ]"
	#/usr/lib/autorepeater/autorepeater_updater.sh ${1:-global} 0 >/dev/null 2>&1 &
	/usr/lib/autorepeater/autorepeater_updater.sh ${1:-global} 0 &
}
start_daemon_for_all_autorepeater_sections()
{
	local __SECTIONID=""
	config_load "autorepeater"
	__SECTIONID="global"
	load_all_config_options "autorepeater" "$__SECTIONID"
	config_list_foreach_once_atleast "autorepeater" "$__SECTIONID" "interface" start_autorepeater_interface
}
stop_autorepeater_interface(){
	logger "Stop AutoRepeater daemon [ ${1:-global} ]"
	local __PID=0
	local __PIDFILE="$RUNDIR/${1:-global}.pid"
	[ -e "$__PIDFILE" ] && {
		__PID=$(cat $__PIDFILE)
		ps | grep "^[\t ]*$__PID" >/dev/null 2>&1 && kill $__PID || __PID=0
	}
	[ $__PID -eq 0 ]
}
stop_daemon_for_all_autorepeater_sections() {
	local __SECTIONID=""
	config_load "autorepeater"
	__SECTIONID="global"
	config_list_foreach_once_atleast "autorepeater" "$__SECTIONID" "interface" stop_autorepeater_interface
}
write_log() {
	local __LEVEL __EXIT __CMD __MSG
	local __TIME=$(date +%H%M%S)
	[ $1 -ge 10 ] && {
		__LEVEL=$(($1-10))
		__EXIT=1
	} || {
		__LEVEL=$1
		__EXIT=0
	}
	shift
	[ $__EXIT -eq 0 ] && __MSG="$*" || __MSG="$* - TERMINATE"
	case $__LEVEL in
		0)	__CMD="logger -p user.emerg -t autorepeater-scripts[$$] $SECTION_ID: \"$__MSG\""
			__MSG=" $__TIME EMERG : $__MSG" ;;
		1)	__CMD="logger -p user.alert -t autorepeater-scripts[$$] $SECTION_ID: \"$__MSG\""
			__MSG=" $__TIME ALERT : $__MSG" ;;
		2)	__CMD="logger -p user.crit -t autorepeater-scripts[$$] $SECTION_ID: \"$__MSG\""
			__MSG=" $__TIME  CRIT : $__MSG" ;;
		3)	__CMD="logger -p user.err -t autorepeater-scripts[$$] $SECTION_ID: \"$__MSG\""
			__MSG=" $__TIME ERROR : $__MSG" ;;
		4)	__CMD="logger -p user.warn -t autorepeater-scripts[$$] $SECTION_ID: \"$__MSG\""
			__MSG=" $__TIME  WARN : $__MSG" ;;
		5)	__CMD="logger -p user.notice -t autorepeater-scripts[$$] $SECTION_ID: \"$__MSG\""
			__MSG=" $__TIME  note : $__MSG" ;;
		6)	__CMD="logger -p user.info -t autorepeater-scripts[$$] $SECTION_ID: \"$__MSG\""
			__MSG=" $__TIME  info : $__MSG" ;;
		7)	__MSG=" $__TIME       : $__MSG";;
		*) 	return;;
	esac
	[ $VERBOSE_MODE -gt 0 -o $__EXIT -gt 0 ] && echo -e "$__MSG"
	if [ ${use_logfile:-1} -eq 1 -o $VERBOSE_MODE -gt 1 ]; then
		echo -e "$__MSG" >> $LOGFILE
		[ $VERBOSE_MODE -gt 1 ] || sed -i -e :a -e '$q;N;'$LOGLINES',$D;ba' $LOGFILE
	fi
	[ $LUCI_HELPER ]   && return
	[ $__LEVEL -eq 7 ] && return
	__CMD=$(echo -e "$__CMD" | tr -d '\n' | tr '\t' '     ')
	[ $__EXIT  -eq 1 ] && {
		$__CMD
		exit 1
	}
	[ $use_syslog -eq 0 ] && return
	[ $((use_syslog + __LEVEL)) -le 7 ] && $__CMD
	return
}
urlencode() {
	local __STR __LEN __CHAR __OUT
	local __ENC=""
	local __POS=1
	[ $# -ne 2 ] && write_log 12 "Error calling 'urlencode()' - wrong number of parameters"
	__STR="$2"
	__LEN=${#__STR}
	while [ $__POS -le $__LEN ]; do
		__CHAR=$(expr substr "$__STR" $__POS 1)
		case "$__CHAR" in
		        [-_.~a-zA-Z0-9] )
				__OUT="${__CHAR}"
				;;
		        * )
		               __OUT=$(printf '%%%02x' "'$__CHAR" )
				;;
		esac
		__ENC="${__ENC}${__OUT}"
		__POS=$(( $__POS + 1 ))
	done
	eval "$1=\"$__ENC\""
	return 0
}
get_seconds() {
	[ $# -ne 3 ] && write_log 12 "Error calling 'get_seconds()' - wrong number of parameters"
	case "$3" in
		"days" )	eval "$1=$(( $2 * 86400 ))";;
		"hours" )	eval "$1=$(( $2 * 3600 ))";;
		"minutes" )	eval "$1=$(( $2 * 60 ))";;
		* )		eval "$1=$2";;
	esac
	return 0
}
timeout() {
#.copied from http://www.ict.griffith.edu.au/anthony/software/timeout.sh
#.Anthony Thyssen     6 April 2011
	SIG=-TERM
	while [ $# -gt 0 ]; do
		case "$1" in
			--)
				shift;
				break ;;
			[0-9]*)
				TIMEOUT="$1" ;;
			-*)
				SIG="$1" ;;
			*)
				break ;;
		esac
		shift
	done
	"$@" &
	command_pid=$!
	sleep_pid=0
	(
		trap 'kill -TERM $sleep_pid; return 1' 1 2 3 15
		sleep $TIMEOUT &
		sleep_pid=$!
		wait $sleep_pid
		kill $SIG $command_pid >/dev/null 2>&1
		return 1
	) &
	timeout_pid=$!
	wait $command_pid
	status=$?
	kill $timeout_pid 2>/dev/null
	wait $timeout_pid 2>/dev/null
	return $status
}
verify_proxy() {
	local __TMP __HOST __PORT
	local __ERR=255
	local __CNT=0
	[ $# -ne 1 ] && write_log 12 "Error calling 'verify_proxy()' - wrong number of parameters"
	write_log 7 "Verify Proxy server 'http://$1'"
	__TMP=$(echo $1 | awk -F "@" '{print $2}')
	[ -z "$__TMP" ] && __TMP="$1"
	__HOST=$(echo $__TMP | grep -m 1 -o "$IPV6_REGEX")
	if [ -n "$__HOST" ]; then
		__PORT=$(echo $__TMP | awk -F "]:" '{print $2}')
	else
		__HOST=$(echo $__TMP | awk -F ":" '{print $1}')
		__PORT=$(echo $__TMP | awk -F ":" '{print $2}')
	fi
	[ -z "$__PORT" ] && {
		[ $LUCI_HELPER ] && return 5
		write_log 14 "Invalid Proxy server Error '5' - proxy port missing"
	}
	while [ $__ERR -gt 0 ]; do
		verify_host_port "$__HOST" "$__PORT"
		__ERR=$?
		if [ $LUCI_HELPER ]; then
			return $__ERR
		elif [ $__ERR -gt 0 -a $VERBOSE_MODE -gt 1 ]; then
			write_log 4 "Verify Proxy server '$1' failed - Verbose Mode: $VERBOSE_MODE - NO retry on error"
			return $__ERR
		elif [ $__ERR -gt 0 ]; then
			__CNT=$(( $__CNT + 1 ))
			[ $retry_count -gt 0 -a $__CNT -gt $retry_count ] && \
				write_log 14 "Verify Proxy server '$1' failed after $retry_count retries"
			write_log 4 "Verify Proxy server '$1' failed - retry $__CNT/$retry_count in $RETRY_SECONDS seconds"
			sleep $RETRY_SECONDS &
			PID_SLEEP=$!
			wait $PID_SLEEP
			PID_SLEEP=0
		fi
	done
	return 0
}
get_uptime() {
	[ $# -ne 1 ] && write_log 12 "Error calling 'verify_host_port()' - wrong number of parameters"
	local __UPTIME=$(cat /proc/uptime)
	eval "$1=\"${__UPTIME%%.*}\""
}
trap_handler() {
	local __PIDS __PID
	local __ERR=${2:-0}
	local __OLD_IFS=$IFS
	local __NEWLINE_IFS='
'
	[ $PID_SLEEP -ne 0 ] && kill -$1 $PID_SLEEP 2>/dev/null
	case $1 in
		 0)	if [ $__ERR -eq 0 ]; then
				write_log 5 "PID '$$' exit normal at $(eval $DATE_PROG)\n"
			else
				write_log 4 "PID '$$' exit WITH ERROR '$__ERR' at $(eval $DATE_PROG)\n"
			fi ;;
		 1)	write_log 6 "PID '$$' received 'SIGHUP' at $(eval $DATE_PROG)"
			eval "/usr/lib/autorepeater/autorepeater_updater.sh $SECTION_ID $VERBOSE_MODE &"
			exit 0 ;;
		 2)	write_log 5 "PID '$$' terminated by 'SIGINT' at $(eval $DATE_PROG)\n";;
		 3)	write_log 5 "PID '$$' terminated by 'SIGQUIT' at $(eval $DATE_PROG)\n";;
		15)	write_log 5 "PID '$$' terminated by 'SIGTERM' at $(eval $DATE_PROG)\n";;
		 *)	write_log 13 "Unhandled signal '$1' in 'trap_handler()'";;
	esac
	__PIDS=$(pgrep -P $$)
	IFS=$__NEWLINE_IFS
	for __PID in $__PIDS; do
		kill -$1 $__PID
	done
	IFS=$__OLD_IFS
	[ -f $DATFILE ] && rm -f $DATFILE
	[ -f $ERRFILE ] && rm -f $ERRFILE
	trap - 0 1 2 3 15
	[ $1 -gt 0 ] && kill -$1 $$
}
