#!/bin/sh

#
# (c) 2022-2024 Cezary Jackiewicz <cezary@eko.one.pl>
#

hextobands() {
	BANDS=""
	HEX="$1"
	LEN=${#HEX}
	if [ $LEN -gt 18 ]; then
		CNT=$((LEN - 16))
		HHEX=${HEX:0:CNT}
		HEX="0x"${HEX:CNT}
	fi

	for B in $(seq 0 63); do
		POW=$((2 ** $B))
		T=$((HEX&$POW))
		[ "x$T" = "x$POW" ] && BANDS="${BANDS}$((B + 1)) "
	done
	if [ -n "$HHEX" ]; then
		for B in $(seq 0 63); do
			POW=$((2 ** $B))
			T=$((HHEX&$POW))
			[ "x$T" = "x$POW" ] && BANDS="${BANDS}$((B + 1 + 64)) "
		done
	fi
	echo "$BANDS"
}

bandstohex() {
	BANDS="$1"
	SUM=0
	HSUM=0
	for BAND in $BANDS; do
		case $BAND in
			''|*[!0-9]*) continue ;;
		esac
		if [ $BAND -gt 64 ]; then
			B=$((BAND - 1 - 64))
			POW=$((2 ** $B))
			HSUM=$((HSUM + POW))
		else
			B=$((BAND - 1))
			POW=$((2 ** $B))
			SUM=$((SUM + POW))
		fi
	done
	if [ $HSUM -eq 0 ]; then
		HEX=$(printf '%x' $SUM)
	else
		HEX=$(printf '%x%016x' $HSUM $SUM)
	fi
	echo "$HEX"
}

bandtxt() {
	BAND=$1

# see https://en.wikipedia.org/wiki/LTE_frequency_bands

	case "$BAND" in
	"1") echo " $BAND: FDD 2100 MHz";;
	"2") echo " $BAND: FDD 1900 MHz";;
	"3") echo " $BAND: FDD 1800 MHz";;
	"4") echo " $BAND: FDD 1700 MHz";;
	"5") echo " $BAND: FDD  850 MHz";;
	"7") echo " $BAND: FDD 2600 MHz";;
	"8") echo " $BAND: FDD  900 MHz";;
	"11") echo "$BAND: FDD 1500 MHz";;
	"12") echo "$BAND: FDD  700 MHz";;
	"13") echo "$BAND: FDD  700 MHz";;
	"14") echo "$BAND: FDD  700 MHz";;
	"17") echo "$BAND: FDD  700 MHz";;
	"18") echo "$BAND: FDD  850 MHz";;
	"19") echo "$BAND: FDD  850 MHz";;
	"20") echo "$BAND: FDD  800 MHz";;
	"21") echo "$BAND: FDD 1500 MHz";;
	"24") echo "$BAND: FDD 1600 MHz";;
	"25") echo "$BAND: FDD 1900 MHz";;
	"26") echo "$BAND: FDD  850 MHz";;
	"28") echo "$BAND: FDD  700 MHz";;
	"29") echo "$BAND: SDL  700 MHz";;
	"30") echo "$BAND: FDD 2300 MHz";;
	"31") echo "$BAND: FDD  450 MHz";;
	"32") echo "$BAND: SDL 1500 MHz";;
	"34") echo "$BAND: TDD 2000 MHz";;
	"37") echo "$BAND: TDD 1900 MHz";;
	"38") echo "$BAND: TDD 2600 MHz";;
	"39") echo "$BAND: TDD 1900 MHz";;
	"40") echo "$BAND: TDD 2300 MHz";;
	"41") echo "$BAND: TDD 2500 MHz";;
	"42") echo "$BAND: TDD 3500 MHz";;
	"43") echo "$BAND: TDD 3700 MHz";;
	"46") echo "$BAND: TDD 5200 MHz";;
	"47") echo "$BAND: TDD 5900 MHz";;
	"48") echo "$BAND: TDD 3500 MHz";;
	"50") echo "$BAND: TDD 1500 MHz";;
	"51") echo "$BAND: TDD 1500 MHz";;
	"53") echo "$BAND: TDD 2400 MHz";;
	"54") echo "$BAND: TDD 1600 MHz";;
	"65") echo "$BAND: FDD 2100 MHz";;
	"66") echo "$BAND: FDD 1700 MHz";;
	"67") echo "$BAND: SDL  700 MHz";;
	"69") echo "$BAND: SDL 2600 MHz";;
	"70") echo "$BAND: FDD 1700 MHz";;
	"71") echo "$BAND: FDD  600 MHz";;
	"72") echo "$BAND: FDD  450 MHz";;
	"73") echo "$BAND: FDD  450 MHz";;
	"74") echo "$BAND: FDD 1500 MHz";;
	"75") echo "$BAND: SDL 1500 MHz";;
	"76") echo "$BAND: SDL 1500 MHz";;
	"85") echo "$BAND: FDD  700 MHz";;
	"87") echo "$BAND: FDD  410 MHz";;
	"88") echo "$BAND: FDD  410 MHz";;
	"103") echo "$BAND: FDD  700 MHz";;
	"106") echo "$BAND: FDD  900 MHz";;
	esac
}

bandtxt5g() {
	BAND=$1

# see https://en.wikipedia.org/wiki/5G_NR_frequency_bands

	case "$BAND" in
	"1") echo " $BAND: FDD 2100 MHz";;
	"2") echo " $BAND: FDD 1900 MHz";;
	"3") echo " $BAND: FDD 1800 MHz";;
	"5") echo " $BAND: FDD  850 MHz";;
	"7") echo " $BAND: FDD 2600 MHz";;
	"8") echo " $BAND: FDD  900 MHz";;
	"12") echo "$BAND: FDD  700 MHz";;
	"13") echo "$BAND: FDD  700 MHz";;
	"14") echo "$BAND: FDD  700 MHz";;
	"18") echo "$BAND: FDD  850 MHz";;
	"20") echo "$BAND: FDD  800 MHz";;
	"24") echo "$BAND: FDD 1600 MHz";;
	"25") echo "$BAND: FDD 1900 MHz";;
	"26") echo "$BAND: FDD  850 MHz";;
	"28") echo "$BAND: FDD  700 MHz";;
	"29") echo "$BAND: SDL  700 MHz";;
	"30") echo "$BAND: TDD 2300 MHz";;
	"34") echo "$BAND: TDD 2100 MHz";;
	"38") echo "$BAND: TDD 2600 MHz";;
	"39") echo "$BAND: TDD 1900 MHz";;
	"40") echo "$BAND: TDD 2300 MHz";;
	"41") echo "$BAND: TDD 2500 MHz";;
	"46") echo "$BAND: TDD 5200 MHz";;
	"47") echo "$BAND: TDD 5900 MHz";;
	"48") echo "$BAND: TDD 3500 MHz";;
	"50") echo "$BAND: TDD 1500 MHz";;
	"51") echo "$BAND: TDD 1500 MHz";;
	"53") echo "$BAND: TDD 2400 MHz";;
	"54") echo "$BAND: TDD 1600 MHz";;
	"65") echo "$BAND: FDD 2100 MHz";;
	"66") echo "$BAND: FDD 1700/2100 MHz";;
	"67") echo "$BAND: SDL  700 MHz";;
	"70") echo "$BAND: FDD 2000 MHz";;
	"71") echo "$BAND: FDD  600 MHz";;
	"74") echo "$BAND: FDD 1500 MHz";;
	"75") echo "$BAND: SDL 1500 MHz";;
	"76") echo "$BAND: SDL 1500 MHz";;
	"77") echo "$BAND: TDD 3700 MHz";;
	"78") echo "$BAND: TDD 3500 MHz";;
	"79") echo "$BAND: TDD 4700 MHz";;
	"80") echo "$BAND: SUL 1800 MHz";;
	"81") echo "$BAND: SUL  900 MHz";;
	"82") echo "$BAND: SUL  800 MHz";;
	"83") echo "$BAND: SUL  700 MHz";;
	"84") echo "$BAND: SUL 2100 MHz";;
	"85") echo "$BAND: FDD  700 MHz";;
	"86") echo "$BAND: SUL 1700 MHz";;
	"89") echo "$BAND: SUL  850 MHz";;
	"90") echo "$BAND: TDD 2500 MHz";;
	"91") echo "$BAND: FDD  800/1500 MHz";;
	"92") echo "$BAND: FDD  800/1500 MHz";;
	"93") echo "$BAND: FDD  900/1500 MHz";;
	"94") echo "$BAND: FDD  900/1500 MHz";;
	"95") echo "$BAND: SUL 2100 MHz";;
	"96") echo "$BAND: TDD 6000 MHz";;
	"97") echo "$BAND: SUL 2300 MHz";;
	"98") echo "$BAND: SUL 1900 MHz";;
	"99") echo "$BAND: SUL 1600 MHz)";;
	"100") echo "$BAND: FDD  900 MHz";;
	"101") echo "$BAND: TDD 1900 MHz";;
	"102") echo "$BAND: TDD 6200 MHz";;
	"104") echo "$BAND: TDD 6700 MHz";;
	"105") echo "$BAND: FDD  600 MHz";;
	"257") echo "$BAND: 28 GHz";;
	"258") echo "$BAND: 26 GHz";;
	"259") echo "$BAND: 41 GHz";;
	"260") echo "$BAND: 39 GHz";;
	"261") echo "$BAND: 28 GHz";;
	"262") echo "$BAND: 47 GHz";;
	"263") echo "$BAND: 60 GHz";;
	esac
}

_DEVICE=""
_DEFAULT_LTE_BANDS=""
_DEFAULT_5GNSA_BANDS=""
_DEFAULT_5GSA_BANDS=""

# default templates

# modem name/type
getinfo() {
	echo "Unsupported"
}

# get supported band - 4G
getsupportedbands() {
	echo "Unsupported"
}

getsupportedbandsext() {
	T=$(getsupportedbands)
	[ "x$T" = "xUnsupported" ] && return
	for BAND in $T; do
		bandtxt "$BAND"
	done
}

# get current configured bands - 4G
getbands() {
	echo "Unsupported"
}

getbandsext() {
	T=$(getbands)
	[ "x$T" = "xUnsupported" ] && return
	for BAND in $T; do
		bandtxt "$BAND"
	done
}

# set bands - 4G
setbands() {
	echo "Unsupported"
}

# get supported band - 5G NSA
getsupportedbands5gnsa() {
	echo "Unsupported"
}

getsupportedbandsext5gnsa() {
	T=$(getsupportedbands5gnsa)
	[ "x$T" = "xUnsupported" ] && return
	for BAND in $T; do
		bandtxt5g "$BAND"
	done
}

# get current configured bands - 5G NSA
getbands5gnsa() {
	echo "Unsupported"
}

getbandsext5gnsa() {
	T=$(getbands5gnsa)
	[ "x$T" = "xUnsupported" ] && return
	for BAND in $T; do
		bandtxt5g "$BAND"
	done
}

# set bands - 5G NSA
setbands5gnsa() {
	echo "Unsupported"
}

# get supported band - 5G SA
getsupportedbands5gsa() {
	echo "Unsupported"
}

getsupportedbandsext5gsa() {
	T=$(getsupportedbands5gsa)
	[ "x$T" = "xUnsupported" ] && return
	for BAND in $T; do
		bandtxt5g "$BAND"
	done
}

# get current configured bands - 5G SA
getbands5gsa() {
	echo "Unsupported"
}

getbandsext5gsa() {
	T=$(getbands5gsa)
	[ "x$T" = "xUnsupported" ] && return
	for BAND in $T; do
		bandtxt5g "$BAND"
	done
}

# set bands - 5G SA
setbands5gsa() {
	echo "Unsupported"
}


RES="/usr/share/modemband"

_DEVS=$(awk '{gsub("="," ");
if ($0 ~ /Bus.*Lev.*Prnt.*Port.*/) {T=$0}
if ($0 ~ /Vendor.*ProdID/) {idvendor[T]=$3; idproduct[T]=$5}
if ($0 ~ /Product/) {product[T]=$3}}
END {for (idx in idvendor) {printf "%s%s\n%s%s%s\n", idvendor[idx], idproduct[idx], idvendor[idx], idproduct[idx], product[idx]}}' /sys/kernel/debug/usb/devices)
for _DEV in $_DEVS; do
	if [ -e "$RES/$_DEV" ]; then
		. "$RES/$_DEV"
		break
	fi
done

if [ -z "$_DEVICE" ]; then
	if [ "x$1" = "xjson" ]; then
		echo '{"error":"No supported modem was found, quitting..."}'
	else
		echo "No supported modem was found, quitting..."
	fi
	exit 0
else
	_DEVICE1=$(uci -q get modemband.@modemband[0].set_port)
	if [ -n "$_DEVICE1" ]; then
		_DEVICE=$_DEVICE1
	fi
fi
if [ ! -e "$_DEVICE" ]; then
	if [ "x$1" = "xjson" ]; then
		echo '{"error":"Port not found, quitting..."}'
	else
		echo "Port not found, quitting..."
	fi
	exit 0
fi

case $1 in
	"getinfo")
		getinfo
		;;
	"getsupportedbands")
		getsupportedbands
		;;
	"getsupportedbandsext")
		getsupportedbandsext
		;;
	"getbands")
		getbands
		;;
	"getbandsext")
		getbandsext
		;;
	"setbands")
		[ -n "$2" ] && setbands "$2"
		;;
	"getsupportedbands5gnsa")
		getsupportedbands5gnsa
		;;
	"getsupportedbandsext5gnsa")
		getsupportedbandsext5gnsa
		;;
	"getbands5gnsa")
		getbands5gnsa
		;;
	"getbandsext5gnsa")
		getbandsext5gnsa
		;;
	"setbands5gnsa")
		[ -n "$2" ] && setbands5gnsa "$2"
		;;
	"getsupportedbands5gsa")
		getsupportedbands5gsa
		;;
	"getsupportedbandsext5gsa")
		getsupportedbandsext5gsa
		;;
	"getbands5gsa")
		getbands5gsa
		;;
	"getbandsext5gsa")
		getbandsext5gsa
		;;
	"setbands5gsa")
		[ -n "$2" ] && setbands5gsa "$2"
		;;
	"json")
		. /usr/share/libubox/jshn.sh
		json_init
		json_add_string modem "$(getinfo)"
		json_add_array supported
		T=$(getsupportedbands)
		if [ "x$T" != "xUnsupported" ]; then
			for BAND in $T; do
				json_add_object ""
				json_add_int band $BAND
				TXT="$(bandtxt $BAND)"
				json_add_string txt "${TXT##*: }"
				json_close_object
			done
		fi
		json_close_array
		json_add_array enabled
		T=$(getbands)
		if [ "x$T" != "xUnsupported" ]; then
			for BAND in $T; do
				json_add_int "" $BAND
			done
		fi
		json_close_array

		T=$(getsupportedbands5gnsa)
		if [ "x$T" != "xUnsupported" ]; then
			json_add_array supported5gnsa
			for BAND in $T; do
				json_add_object ""
				json_add_int band $BAND
				TXT="$(bandtxt5g $BAND)"
				json_add_string txt "${TXT##*: }"
				json_close_object
			done
			json_close_array
			json_add_array enabled5gnsa
			T=$(getbands5gnsa)
			if [ "x$T" != "xUnsupported" ]; then
				for BAND in $T; do
					json_add_int "" $BAND
				done
			fi
			json_close_array
		fi
		T=$(getsupportedbands5gsa)
		if [ "x$T" != "xUnsupported" ]; then
			json_add_array supported5gsa
			for BAND in $T; do
				json_add_object ""
				json_add_int band $BAND
				TXT="$(bandtxt5g $BAND)"
				json_add_string txt "${TXT##*: }"
				json_close_object
			done
			json_close_array
			json_add_array enabled5gsa
			T=$(getbands5gsa)
			if [ "x$T" != "xUnsupported" ]; then
				for BAND in $T; do
					json_add_int "" $BAND
				done
			fi
			json_close_array
		fi
		json_dump
		;;
	"help")
		echo "Available commands:"
		echo " $0 getinfo"
		echo " $0 json"
		echo " $0 help"
		echo ""
		echo "for LTE modem"
		echo " $0 getsupportedbands"
		echo " $0 getsupportedbandsext"
		echo " $0 getbands"
		echo " $0 getbandsext"
		echo " $0 setbands \"<band list>\""
		echo ""
		echo "for 5G NSA modem"
		echo " $0 getsupportedbands5gnsa"
		echo " $0 getsupportedbandsext5gnsa"
		echo " $0 getbands5gnsa"
		echo " $0 getbandsext5gnsa"
		echo " $0 setbands5gnsa \"<band list>\""
		echo ""
		echo "for 5G SA modem"
		echo " $0 getsupportedbands5gsa"
		echo " $0 getsupportedbandsext5gsa"
		echo " $0 getbands5gsa"
		echo " $0 getbandsext5gsa"
		echo " $0 setbands5gsa \"<band list>\""
		;;
	*)
		echo -n "Modem: "
		getinfo
		echo -n "Supported LTE bands: "
		getsupportedbands
		echo -n "Enabled LTE bands: "
		getbands
		echo ""
		getsupportedbandsext
		T=$(getsupportedbands5gnsa)
		if [ "x$T" != "xUnsupported" ]; then
			echo -n "Supported 5G NSA bands: "
			getsupportedbands5gnsa
			echo -n "Enabled 5G NSA bands: "
			getbands5gnsa
			echo ""
			getsupportedbandsext5gnsa
		fi
		T=$(getsupportedbands5gsa)
		if [ "x$T" != "xUnsupported" ]; then
			echo -n "Supported 5G SA bands: "
			getsupportedbands5gsa
			echo -n "Enabled 5G SA bands: "
			getbands5gsa
			echo ""
			getsupportedbandsext5gsa
		fi
		;;
esac

exit 0
