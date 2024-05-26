#!/bin/sh
# <https://github.com/alexwbaule/telegramopenwrt/blob/master/plugins/wifi_list>

old=$IFS
IFS=$'\n'
TOTAL=0

echo "*Wireless*"

for rule in $(uci show wireless  | grep "default_radio" )
do
	line=$(echo ${rule} | awk -F "." '{print $3}')
	id=$(echo ${rule} | grep ".ssid" | grep -oE "\[[[:digit:]]+\]" | awk '{gsub("\\[|]","");printf $1}')
	if [ "$id" != "" ]; then
		echo "rate: "$(iwinfo wlan${id} info | grep -oE "[[:digit:]]+\.[[:digit:]]+ MBit\/s")
		awk 'BEGIN{x='$(iwinfo wlan${id} info | grep -oE "[[:digit:]]+/[[:digit:]]+")' * 100; printf "quality: %.0f%%\n", x}'
	fi
	new=${line//\'/}
	new2=${new//_/\\_}
	new3=${new2//=/: }
	echo ${new3//\*/all}
done
IFS=$old