#!/bin/sh

SECTIONS=$(echo $(uci show ttl | awk -F [\]\[\@=] '/=ttl/{print $3}'))

get_vars(){
	for v in method advanced inet ports ttl iface; do
		eval $v=$(uci -q get ttl.@ttl[${s}].${v} 2>/dev/nul)
	done
}



method_ttl(){
	if [ ! $ttl ]; then
		ttl=64
	fi
	case $(($ttl % 2)) in
		0) TTL_INC=4 ;;
		*) TTL_INC=5 ;;
	esac
	for T in $IPT; do
		case $T in
			iptables)
				SUFFIX="TTL --ttl-set"
				if [ $iface ]; then
					$T -t mangle -A TTLFIX -i $DEV -m ttl --ttl 1 -j TTL --ttl-inc $TTL_INC
				else
					$T -t mangle -A TTLFIX -m ttl --ttl 1 -j TTL --ttl-inc $TTL_INC
				fi
			;;
			ip6tables)
				SUFFIX="HL --hl-set"
				if [ $iface ]; then
					$T -t mangle -A TTLFIX -i $DEV -m hl --hl 1 -j HL --hl-inc $TTL_INC
				else
					$T -t mangle -A TTLFIX -m hl --hl 1 -j HL --hl-inc $TTL_INC
				fi
			;;
		esac

		if [ $iface ]; then
			$T -t mangle -A TTL_OUT -o $DEV -j $SUFFIX $ttl
			$T -t mangle -A TTL_POST -o $DEV -j $SUFFIX $ttl
		else
			$T -t mangle -A TTL_OUT -j $SUFFIX $ttl
			$T -t mangle -A TTL_POST -j $SUFFIX $ttl
		fi
	done				
}


method_proxy(){
	for T in $IPT; do
		case $T in
			iptables)
				IPADDR=$(ifstatus $iface | jsonfilter -e '@["ipv4-address"][*]["address"]')
				END="${IPADDR}:3128"
			;;
			ip6tables)
				for a in $(ifstatus $iface | jsonfilter -e '@["ipv6-prefix-assignment"][*]["local-address"]["address"]'); do
					IPADDR="$a"
				done
				END="[$IPADDR]:3128"
			;;
		esac

		$T -t nat -A PROXY -i $DEV -j FIXPROXY
		
		case $ports in
			all)
				$T -t nat -A FIXPROXY ! -d ${IPADDR} \
					! -s ${IPADDR} -p tcp \
					-j DNAT --to-destination $END
			;;
			http)
				$T -t nat -A FIXPROXY ! -d ${IPADDR} \
					! -s ${IPADDR} -p tcp -m multiport \
					--dports 80,443 -j DNAT --to-destination $END
			;;
			*)
				if [ $ports ]; then
					$T -t nat -A FIXPROXY ! -d ${IPADDR} \
						! -s ${IPADDR} -p tcp -m multiport \
						--dports $ports -j DNAT --to-destination $END
				else
					$T -t nat -A FIXPROXY ! -d ${IPADDR} \
						! -s ${IPADDR} -p tcp \
						-j DNAT --to-destination $END
				fi
			;;
		esac
	done
}	

# check nat66 module
if [ -f /lib/modules/$(uname -r)/ip6table_nat.ko ]; then
	IPT="iptables ip6tables"
else
	IPT="iptables"
fi
	
# Create and flush mangle table
for T in $IPT; do
	for t in N F; do
		for c in TTLFIX TTL_OUT TTL_POST; do
			$T -t mangle -${t} ${c}
		done
	done
	for a in D A; do
		$T -t mangle -${a} PREROUTING -j TTLFIX
		$T -t mangle -${a} OUTPUT -j TTL_OUT
		$T -t mangle -${a} POSTROUTING -j TTL_POST
	done
done

# Create and flush nat table
for T in $IPT; do
	for t in N F; do
		$T -t nat -${t} PROXY
		$T -t nat -${t} FIXPROXY
	done
	for a in D I; do
		$T -t nat -${a} PREROUTING -j PROXY
	done
done

for s in $SECTIONS; do
	if [ "$s" ]; then
		get_vars
	else
		exit 0
	fi
	case $inet in
		ipv4) IPT="iptables" ;;
		ipv6) IPT="ip6tables" ;;
		*) IPT="iptables ip6tables";;
	esac
	if ! [ -f /lib/modules/$(uname -r)/ip6table_nat.ko ]; then
		IPT="iptables"
	fi
	DEV=$(ifstatus $iface | jsonfilter -e '@["l3_device"]')
	case $method in
		ttl) method_ttl ;;
		proxy) method_proxy ;;
	esac
done
