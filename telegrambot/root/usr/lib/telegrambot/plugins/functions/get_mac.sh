#!/bin/sh

PUREMAC="${1:0:8}"
LMAC=$(echo $PUREMAC | awk '{ print toupper($0) }')
MAC=${LMAC//:/}

maclist=$(curl -s -k -L -X GET -H "Content-Type: application/json; charset=utf-8" \
	-H "Origin: https://regauth.standards.ieee.org" \
	-H "Referer: https://regauth.standards.ieee.org/standards-ra-web/pub/view.html" \
	"https://services13.ieee.org/RST/standards-ra-web/rest/assignments/?registry=MA-L&sortby=organization&sortorder=asc&text=${MAC}")

IDS=${MAC//-/}
HEX=$(jsonfilter -s "$maclist" -e $.data.hits[*].assignmentNumberHex)

i=0
for hexs in $HEX
do
	if [ "$hexs" == "$IDS" ]; then
		name=$(jsonfilter -s "$maclist" -e $.data.hits[$i].organizationName)
		#echo "Identifier: $LMAC"
		echo "Organization: $name"
		exit
	fi
	i=$((i+1))
done
echo "Organization: Not Found!"