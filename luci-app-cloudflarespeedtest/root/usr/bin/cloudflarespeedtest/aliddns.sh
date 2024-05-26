#!/bin/sh
LOG_FILE='/var/log/cloudflarespeedtest.log'

echolog() {
	local d="$(date "+%Y-%m-%d %H:%M:%S")"
	echo -e "$d: $*" >>$LOG_FILE
}

urlencode() {
	# urlencode url<string>
	out=''
	for c in $(echo -n $1 | sed 's/[^\n]/&\n/g'); do
		case $c in
			[a-zA-Z0-9._-]) out="$out$c" ;;
			*) out="$out$(printf '%%%02X' "'$c")" ;;
		esac
	done
	echo -n $out
}

send_request() {
	# send_request action<string> args<string>
	local args="AccessKeyId=$ak_id&Action=$1&Format=json&$2&Version=2015-01-09"
	local hash=$(urlencode $(echo -n "GET&%2F&$(urlencode $args)" | openssl dgst -sha1 -hmac "$ak_sec&" -binary | openssl base64))
	curl -sSL --connect-timeout 5 "http://alidns.aliyuncs.com/?$args&Signature=$hash"
}

get_recordid() {
	sed 's/RR/\n/g' | sed -n 's/.*RecordId[^0-9]*\([0-9]*\).*/\1\n/p' | sort -ru | sed /^$/d
}

query_recordid() {
	send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&SubDomain=$sub_dm.$main_dm&Timestamp=$timestamp&Type=A"
}

update_record() {
	send_request "UpdateDomainRecord" "Line=$line&RR=$sub_dm&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&Timestamp=$timestamp&Type=$type&Value=$ip"
}

add_record() {
	send_request "AddDomainRecord&DomainName=$main_dm" "Line=$line&RR=$sub_dm&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&Timestamp=$timestamp&Type=$type&Value=$ip"
}

del_record() {
	send_request "DeleteDomainRecord" "RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$timestamp&SignatureVersion=1.0&Timestamp=$timestamp"
}

aliddns() {
	ak_id=$1
	ak_sec=$2
	main_dm=$3
	sub_dm=$4
	line=$5
	isIpv6=$6
	ip=$7
	type=A
	
	if [ $isIpv6 -eq "1" ] ;then
		type=AAAA
	fi
echo  $ip
echo  $type
	rrid=`query_recordid | get_recordid`
	
	if [ -z "$rrid" ]; then
		rrid=`add_record | get_recordid`
		echolog "ADD record $rrid"
	else
		update_record $rrid
		echolog "UPDATE record $rrid"
	fi
	if [ -z "$rrid" ]; then
		# failed
		echolog "# ERROR, Please Check Config/Time"
	fi
}


timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")

aliddns "$@"
