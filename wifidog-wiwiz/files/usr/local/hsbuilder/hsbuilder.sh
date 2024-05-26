#!/bin/sh
# Wiwiz HotSpot Builder Utility
# Copyright wiwiz.com. All rights reserved.

MY_VERSION="$(cat /usr/local/hsbuilder/ver 2>/dev/null)"  #for Wiwiz-opensource

#SRV_SAVE='/usr/local/hsbuilder/srv'
ENVINFO='wiwiz-opensource'
CONFPATH='/usr/local/hsbuilder/hsbuilder.conf'
ADDRLIST='/tmp/hsbuilder_addrlist.txt'
TRUSTMAC='/tmp/hsbuilder_trustmac'
DOMAINNAME='/tmp/hsbuilder_domainname.txt'
TIMEOUT="10"
IPLIST='/tmp/hsbuilder_iplist.txt'
BLOCKPORT='/tmp/hsbuilder_blockport.txt'
USERBLOCKPORT='/tmp/hsbuilder_userblockport.txt'
WD_CONF_TMP='/tmp/hsbuilder_wdconf.tmp'
LOGFILE='/tmp/hsbuilder.log'
#AD_STATUS='/tmp/hsbuilder_ad.txt'
#AD_STATUS_V='0'
#AD_CONFIG='/tmp/hsbuilder_ad_conf.tmp'
EOF_FLAG='###END_OF_FILE###'
WDCTL="wdctl"
NSLOOKUPOK="1"
SORT="1"
which sort 1>/dev/null 2>/dev/null
if [ $? != 0 ]; then
	SORT="0"	#no sort
else
	SORT="1"
fi

#MY_FULLPATH=$(dirname -- $(readlink -f -- "$0"))/hsbuilder.sh
MY_FULLPATH="/usr/local/hsbuilder/hsbuilder.sh"
MSG_FILE="/usr/local/hsbuilder/msgfile.htm"
NORESOLVE="false"

ENVINFO_SENT='0'

doConfig() {
	SURL="$1"
	NR="$2"
	
	#get config data
	#wget -O - -T 10 "$SURL" > $ADDRLIST 2>/dev/null
	curl -m 10 -o "$ADDRLIST" "$SURL" 2>/dev/null
	
	if [ "`tail -n 1 $ADDRLIST`" = $EOF_FLAG ]; then
		cat $ADDRLIST | grep -v "$EOF_FLAG" | while read LINE; do
			#echo LINE=$LINE
			ACTION=$(echo $LINE | cut -d " " -f 1)
			ACDATA=$(echo $LINE | cut -d " " -f 2)

			if [ "$ACTION" = "TM" ]; then
				echo "$ACDATA" >$TRUSTMAC
			elif [ "$ACTION" = "TO" ]; then
				TIMEOUT="$ACDATA"
			    echo "$(cat $CONFPATH | grep -v TIMEOUT)" > "$CONFPATH"
			    echo "TIMEOUT=$TIMEOUT" >> "$CONFPATH"				
			elif [ "$ACTION" = "UW" ]; then
				makeFwRule "$ACDATA" "FirewallRule allow to" "$NR" "U" "$IPLIST"
			elif [ "$ACTION" = "UB" ]; then
				makeFwRule "$ACDATA" "FirewallRule block to" "$NR" "U" "$IPLIST"
			elif [ "$ACTION" = "SW" ]; then
				makeFwRule "$ACDATA" "FirewallRule allow to" "$NR" "S" "$IPLIST"
			elif [ "$ACTION" = "SB" ]; then
				makeFwRule "$ACDATA" "FirewallRule block to" "$NR" "S" "$IPLIST"
			elif [ "$ACTION" = "BP" ]; then
				PORTTYPE=$(echo $ACDATA | cut -d ":" -f 1)
				PORTNUM=$(echo $ACDATA | cut -d ":" -f 2)				
				echo "FirewallRule block $PORTTYPE port $PORTNUM" >>"$BLOCKPORT"
			elif [ "$ACTION" = "UP" ]; then
				PORTTYPE=$(echo $ACDATA | cut -d ":" -f 1)
				PORTNUM=$(echo $ACDATA | cut -d ":" -f 2)				
				echo "FirewallRule block $PORTTYPE port $PORTNUM" >>"$USERBLOCKPORT"
			#elif [ "$ACTION" = "AD" ]; then
			#	echo $ACDATA >"$AD_STATUS"
			fi
		done
	else
#		echo "Data Download Failed."
		return 1	  
	fi
	
	return 0
}

makeFwRule() {
#	SURL="$1"
	DATA="$1"
	PRX="$2"
	NR="$3"
	COMMENT='#'"$4"
	OUTPUT="$5"
	
	#get address
    ADDRTYPE=$(echo $DATA | cut -d ":" -f 1)
    ADDR=$(echo $DATA | cut -d ":" -f 2)
    
    # if it is a domain name
    if [ "$ADDRTYPE" = "DN" ]; then
    	DOMAIN=$ADDR
    	if [ "$COMMENT" = '#U' ]; then
    		echo "U:DN:$DOMAIN" >>$DOMAINNAME
    	fi
    	
    	#if [ "$NR" != "true" ]; then
    	if [ "$NR" = "true" -a "$COMMENT" != '#U' ]; then
    		NOTHINGTODO=1
    	else
    		#which nslookup 1>/dev/null 2>/dev/null
	        #if [ $? != 0 ]; then
	        if [ "$NSLOOKUPOK" != "1" ]; then
	            ADDR=`ping -c 1 $ADDR 2>>$LOGFILE | grep PING | awk '{print $3}' | tr -d "(" | tr -d ")"`
	            if [ "$ADDR" != "" ]; then
	            	if [ "$COMMENT" = '#U' ]; then
	            		GRP=$(grep "$PRX $ADDR" $OUTPUT)
	            		if [ "$GRP"='' ]; then
	            			echo "$PRX $ADDR    $COMMENT:DN:$DOMAIN" >>$OUTPUT
	            		fi
	            	else
	            		echo "$PRX $ADDR    $COMMENT" >>$OUTPUT
	            	fi
				fi
	        else
	            NSLKP_RST="/tmp/hsbuilder_nslookup.txt"
	            nslookup $ADDR | tail -n +5 | grep Address | cut -d ":" -f 2 | cut -d " " -f 2 > $NSLKP_RST
	            
	            cat $NSLKP_RST | while read LINE2; do
	            	if [ "$COMMENT" = '#U' ]; then
	            		GRP=$(grep "$PRX $LINE2" $OUTPUT)
	            		if [ "$GRP"='' ]; then
	                		echo "$PRX $LINE2    $COMMENT:DN:$DOMAIN" >>$OUTPUT
	                	fi
	                else
	                	echo "$PRX $LINE2    $COMMENT" >>$OUTPUT
	                fi
	            done
	            
	            rm -f $NSLKP_RST
	        fi
	    fi
    # if it is an IP
    else
        if [ "$ADDR" != "" ]; then
        	if [ "$COMMENT" = '#U' ]; then
				GRP=$(grep "$PRX $ADDR" $OUTPUT)
	            if [ "$GRP"='' ]; then
        			echo "$PRX $ADDR    $COMMENT" >>$OUTPUT
        		fi
        	else
        		echo "$PRX $ADDR    $COMMENT" >>$OUTPUT
        	fi
        fi
    fi
}


if [ "$1" = "-help" ]; then
	echo "Usage:"
	echo "hsbuilder [-conf XXX] [-mypath XXX]"
	echo "To show usage: hsbuilder -help"
	exit 0
fi

if [ "$1" = "-conf" ]; then
	if [ "$2" = "" ]; then
	    CONFPATH=$CONFPATH
	else
	    CONFPATH="$2"
	fi
	shift 2
fi

if [ "$1" = "-mypath" ]; then
	if [ "$2" = "" ]; then
	    MY_FULLPATH=$MY_FULLPATH
	else
	    MY_FULLPATH="$2"
	fi
	shift 2
fi

if [ "$1" = "-msgfile" ]; then
	if [ "$2" = "" ]; then
	    MSG_FILE=$MSG_FILE
	else
	    MSG_FILE="$2"
	fi
	shift 2
fi

if [ "$1" = "-nomsgfile" ]; then
	MSG_FILE=""
	shift 1
fi

if [ "$1" = "-noresolve" ]; then
	NORESOLVE="true"
	shift 1
fi

if [ "$1" = "-envinfo" ]; then
	if [ "$2" = "" ]; then
	    ENVINFO="$ENVINFO"
	else
	    ENVINFO="$2"
	fi
	shift 2
fi

# Starts
while :
do
	if [ -e "$ADDRLIST" ]; then
		echo "Another process is running." >&2
		echo "Another process is running." >>$LOGFILE
		#exit 5
		continue
	fi

	if [ ! -e "$CONFPATH" ]; then
		echo "Configuration File Not Exist." >&2
		echo "Configuration File Not Exist." >>$LOGFILE
		#exit 1
		continue
	fi

	#read conf file
	echo "Reading Configuration ..."
	
	ENABLED=$(uci get wiwiz.portal.enabled 2>/dev/null)
	GW_ID=$(uci get wiwiz.portal.hotspotid | xargs 2>/dev/null)
	USERNAME=$(uci get wiwiz.portal.username 2>/dev/null)
	GWIF=$(uci get wiwiz.portal.lan 2>/dev/null)
	DISABLE_IPV6=$(uci get wiwiz.portal.disable_ipv6 2>/dev/null)
	
	if [ "$ENABLED" != "1" ]; then
		_p=$(ps | grep wifidog | grep -v grep 2>/dev/null)
		if [ "$_p" != "" ]; then
			echo "wiwiz disabled, wifidog shutting down " >>$LOGFILE
			wdctl stop
			
			#uci get network.lan.ipv6 1>/dev/null 2>/dev/null && (uci del network.lan.ipv6 && uci commit)
		fi
		sleep 15
		continue
	else
		if [ "$DISABLE_IPV6" = "1" ]; then
			[ "$(uci get network.lan.ipv6 2>/dev/null)" != "0" ] && {
				uci set network.lan.ipv6='0' && uci commit network
			}
			[ "$(uci get network.wan6.reqaddress 2>/dev/null)" != "none" ] && {
				uci set network.wan6.reqaddress='none' && uci commit network
			}
			[ "$(uci get network.wan6.reqprefix 2>/dev/null)" != "no" ] && {
				uci set network.wan6.reqprefix='no' && uci commit network
			}
		fi
	fi
	
	if [ "$GWIF" = "" ]; then
		GWIF="br-lan"
	fi
	AS_HOSTNAME=$(uci get wiwiz.portal.server 2>/dev/null)
	#AS_HTTPPORT=`cat $CONFPATH | grep -v "^#" | grep AS_HTTPPORT | cut -d = -f 2`
	WIFIDOG_CONFPATH=/etc

	echo "Downloading data and setting up, please wait..."

	_WIFIDOG_CONFFILE=$WIFIDOG_CONFPATH/wifidog.conf
	mkdir -p $WIFIDOG_CONFPATH 2>/dev/null

	rm -f $DOMAINNAME
	rm -f $IPLIST
	rm -f $BLOCKPORT
	rm -f $USERBLOCKPORT
	touch $IPLIST
	touch $BLOCKPORT
	touch $USERBLOCKPORT
	touch $DOMAINNAME
	touch $IPLIST.lasttime
	echo "hsbuilder.sh $MY_VERSION: $(date)" >> $LOGFILE

	AS_HOSTNAME_X=$AS_HOSTNAME
	if [ "$AS_HOSTNAME_X" = "" ]; then
		echo "Server is not reachable." >&2
		echo "Server is not reachable." >>$LOGFILE
		#exit 4
		continue
	fi

	which nslookup 1>/dev/null 2>/dev/null
	if [ $? != 0 ]; then
		NSLOOKUPOK="0"
	else
		NSLOOKUPOK="1"
	fi

	doConfig "http://$AS_HOSTNAME_X/as/s/readconf2/?m=all&gw_id=$GW_ID&username=$USERNAME&envinfo=$ENVINFO&ver=$MY_VERSION" "$NORESOLVE"
	if [ $? != "0" ]; then
		rm -f $ADDRLIST
		rm -f $IPLIST
		rm -f $BLOCKPORT
		rm -f $USERBLOCKPORT
		rm -f $DOMAINNAME
		echo "Configuration Data Download and Setup Failed." >&2
		echo "Configuration Data Download and Setup Failed." >>$LOGFILE
		#exit 2
		sleep 2
		continue
	fi


	if [ "$SORT" = "1" ]; then
		grep '#S' $IPLIST.lasttime >> $IPLIST
		if [ "$(uniq $DOMAINNAME)" != "" ]; then
			grep -f $DOMAINNAME $IPLIST.lasttime >> $IPLIST
		fi
		cat $IPLIST | sort | uniq > $IPLIST.2
	else
		grep '#S' $IPLIST.lasttime > $IPLIST.3
		if [ "$(uniq $DOMAINNAME)" != "" ]; then
			grep -f $DOMAINNAME $IPLIST.lasttime >> $IPLIST.3
		fi

		cat $IPLIST.3 >$IPLIST.2
			
		if [ "$(uniq $IPLIST.3)" != "" ]; then
			uniq $IPLIST | grep -v -f $IPLIST.3 >>$IPLIST.2
		else
			uniq $IPLIST >>$IPLIST.2
		fi
	fi

	#
	grep '#' $IPLIST.2 > $IPLIST.3
	grep -v '(null)' $IPLIST.3 > $IPLIST
	rm -f $IPLIST.2 $IPLIST.3

	## compare IP lists
	#_iplist=$(cat $IPLIST)
	#_iplist_old=$(cat $IPLIST.lasttime)
	#if [ "$_iplist" != "$_iplist_old" ]; then

	_HOST=$(echo "$AS_HOSTNAME_X" | cut -d ':' -f 1)
	_PORT=$(echo "$AS_HOSTNAME_X" | cut -d ':' -f 2)

	#make /tmp/hsbuilder_wdconf.tmp
	echo 'GatewayID '$GW_ID >                             $WD_CONF_TMP
	echo 'ExternalInterface '$ETNIF >>                     $WD_CONF_TMP
	echo 'GatewayInterface '$GWIF >>                     $WD_CONF_TMP

	if [ "$MSG_FILE" != "" ]; then
		echo "HtmlMessageFile $MSG_FILE" >>                 $WD_CONF_TMP
	fi

	echo 'AuthServer {' >>                                 $WD_CONF_TMP
	echo 'Hostname '$_HOST >>                 $WD_CONF_TMP
	echo 'HTTPPort '$_PORT >>                 $WD_CONF_TMP
	echo 'Path /as/s/' >>                         $WD_CONF_TMP
	echo '}' >>                                         $WD_CONF_TMP
	echo 'HTTPDMaxConn 253' >>                             $WD_CONF_TMP

	_TrustMac=$(cat "$TRUSTMAC" 2>/dev/null)
	if [ "$_TrustMac" != "" ]; then
		echo "TrustedMACList $_TrustMac" >>                 $WD_CONF_TMP	#!!!
	fi

	TIMEOUT=`cat $CONFPATH | grep -v "^#" | grep TIMEOUT | cut -d = -f 2`
	echo "ClientTimeout $TIMEOUT" >>                       $WD_CONF_TMP

	echo 'FirewallRuleSet global {' >>                     $WD_CONF_TMP
	cat $IPLIST >>                                      $WD_CONF_TMP       #!!!
	cat $USERBLOCKPORT >>                               $WD_CONF_TMP       #!!!
	echo '}' >>                                         $WD_CONF_TMP
	echo 'FirewallRuleSet validating-users {' >>         $WD_CONF_TMP
	echo 'FirewallRule allow to 0.0.0.0/0' >>         $WD_CONF_TMP
	echo '}' >>                                         $WD_CONF_TMP
	echo 'FirewallRuleSet known-users {' >>             $WD_CONF_TMP
	echo 'FirewallRule allow to 0.0.0.0/0' >>         $WD_CONF_TMP
	echo '}' >>                                         $WD_CONF_TMP
	echo 'FirewallRuleSet unknown-users {' >>             $WD_CONF_TMP
	echo 'FirewallRule allow udp port 53' >>         $WD_CONF_TMP
	echo 'FirewallRule allow tcp port 53' >>         $WD_CONF_TMP
	echo 'FirewallRule allow udp port 67' >>         $WD_CONF_TMP
	echo 'FirewallRule allow tcp port 67' >>         $WD_CONF_TMP
	cat $BLOCKPORT >>                               $WD_CONF_TMP       #!!!
	echo '}' >>                                      $WD_CONF_TMP

	# compare wifidog.conf
	touch $_WIFIDOG_CONFFILE
	_wifidog_conf=$(cat $_WIFIDOG_CONFFILE)
	_wifidog_conf_new=$(cat $WD_CONF_TMP)

	if [ "$_wifidog_conf" != "$_wifidog_conf_new" ]; then
		# generate new wifidog.conf
		cp -f $WD_CONF_TMP $_WIFIDOG_CONFFILE
		
		# reload wifidog.conf
		$WDCTL restart

		# back up iplist
		cp -f $IPLIST $IPLIST.lasttime
		
		echo "Wifidog conf file changed." >>$LOGFILE
	fi


	echo "hsbuilder.sh: done." >>$LOGFILE

	sleep 3
	rm -f $WD_CONF_TMP
	rm -f $ADDRLIST
	rm -f $IPLIST
	rm -f $BLOCKPORT
	rm -f $USERBLOCKPORT
	rm -f $DOMAINNAME
	rm -f $TRUSTMAC 2>/dev/null
	
	sleep 20
	/usr/local/hsbuilder/hsbuilder_helper.sh -os openwrt
	
	if [ "$ENVINFO_SENT" = "0" ]; then
		MODEL=$(/usr/local/hsbuilder/getmodel.sh)
		curl -m 5 --data "e2=$ENVINFO_$MY_VERSION|$MODEL" "http://$AS_HOSTNAME_X/as/s/readconf/?m=info&gw_id=$GW_ID&ver=$MY_VERSION" 1>/dev/null 2>/dev/null
		ENVINFO_SENT=1
	fi
	
	sleep 20
done