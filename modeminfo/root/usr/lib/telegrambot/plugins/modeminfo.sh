#!/bin/sh
DATA=$(/usr/share/modeminfo/modeminfo)
SECTIONS=$(echo $(uci show modeminfo | awk -F [\]\[\@=] '/=modeminfo/{print $3}'))

# load channel to band converter
. /usr/share/modeminfo/scripts/ch_to_band

get_data(){
	jsonfilter -s "$DATA" -e "MODE=$['modem'][$s]['mode']" \
		-e "DEVICE=$['modem'][$s]['device']" \
		-e "CH=$['modem'][$s]['arfcn']" \
		-e "COPS=$['modem'][$s]['cops']" \
		-e "PERS=$['modem'][$s]['csq_per']" \
		-e "CA=$['modem'][$s]['lteca']" \
		-e "RSSI=$['modem'][$s]['rssi']" \
		-e "RSRP=$['modem'][$s]['rsrp']" \
		-e "RSRQ=$['modem'][$s]['rsrq']" \
		-e "SINR=$['modem'][$s]['sinr']" \
		-e "ENBID=$['modem'][$s]['enbid']" \
		-e "PCI=$['modem'][$s]['pci']" \
		-e "CELL=$['modem'][$s]['cell']" \
		-e "DIST=$['modem'][$s]['distance']" \
		-e "SB=$['modem'][$s]['scc']"
}

for s in ${SECTIONS}; do
	eval $(echo "$(get_data)" | sed -e 's/export//g')
	ch_to_band $CH
	echo -ne "*Modem $(($s+1))*\n"
	echo -ne "*Device:* $DEVICE\n*Operator:* $COPS 📶${PERS}% $MODE\n"
	case $MODE in
		LTE)
			if [ $CA -ge 1 ]; then
				CA="$(($CA+1))xCA"
				BAND="${SC}${SB}"
				echo -ne "*CA:* $CA BAND ($BAND)\n"
			else
				echo -ne "*BAND:* $SC\n"
			fi
			echo -ne "*RSSI/RSRP:* ${RSSI}dBm/${RSRP}dBm\n*RSRQ/SINR:* ${RSRQ}dB/${SINR}dB\n*eNBID-Cell/PCI:* ${ENBID}-${CELL}/${PCI}"
			if [ "$DIST" ] && [ "$DIST" != "0.00" ]; then
				echo -ne " ~${DIST}km\n"
			else
				echo -ne "\n"
			fi
		;;
		UMT*|WCD*|*HSP*|*HUS*)
			echo -ne "*BAND:* $SC\n"
			echo -ne "*RSSI/ECIO:* ${RSSI}dBm/${SINR}dB\n*LAC/CID:* ${LAC}/${CID}"
		;;
		*)
			echo -ne "*BAND:* $SC\n"
			echo -ne "*RSSI:*  ${RSSI}dBm\n*LAC/CID:* ${LAC}/${CID}"
		;;
	esac
			
	echo -e "\n"
done
