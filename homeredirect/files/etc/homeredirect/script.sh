#!/bin/bash

del_rule() {
	count=$(iptables -n -L INPUT 2>/dev/null | grep -c "HOME_REDIRECT")
	if [ -n "$count" ]; then
		until [ "$count" = 0 ]
		do
			rules=$(iptables -n -L INPUT --line-num 2>/dev/null | grep "HOME_REDIRECT" | awk '{print $1}')
			for rule in $rules
			do
				iptables -D INPUT $rule 2>/dev/null
				break
			done
			count=$(expr $count - 1)
		done
	fi

	iptables -F HOME_REDIRECT 2>/dev/null
	iptables -X HOME_REDIRECT 2>/dev/null
}

add_rule(){
	iptables -N HOME_REDIRECT
	iptables -I INPUT -j HOME_REDIRECT

	maxRedirctCount=$(uci show homeredirect | grep @redirect | awk -F '[' '{print $2}' | awk -F ']' '{print $1}' | sort | tail -n 1)

	for ((i=($maxRedirctCount);i>=0;i--));
	do
		enabled=$(uci get homeredirect.@redirect[$i].enabled)
		if [ $enabled -eq 1 ]; then
			protoAll=$(uci get homeredirect.@redirect[$i].proto)
			proto=${protoAll:0:3}
			port=$(uci get homeredirect.@redirect[$i].src_dport)
			iptables -A HOME_REDIRECT -p $proto --dport $port -j ACCEPT
		fi
	done
}

del_rule

enable=$(uci get homeredirect.@global[0].enabled)
if [ $enable -eq 1 ]; then
	add_rule
fi
