#!/bin/sh

	scan_madwifi()
	{
		aths=$(iwconfig 2>/dev/null | grep -o "^ath..")
		scanif=""
		created=""
		for ath in $aths ; do
			if [ -z "$scanif" ] ; then 
				test=$(iwconfig $ath | grep "anaged")
				if [ -z "$test" ] ; then
					test=$(iwconfig $ath | grep "aster")
				fi
				if [ -n "$test" ] ; then
					scanif="$ath"
				fi
			fi
		done

		if [ -z "$scanif" ] ; then
			created="ath0"
			scanif=$created
			wlanconfig $created create wlandev wifi0 wlanmode sta >/dev/null 2>&1
		fi

		is_up=$(ifconfig 2>/dev/null | grep $scanif)
		if [ -z "$is_up" ] ; then
			ifconfig $scanif up
		fi
		sleep 4


		iwinfo $scanif scan  2>/dev/null

		if [ -z "$is_up" ] ; then
			ifconfig $scanif down 2>/dev/null
		fi
		if [ -n "$created" ] ; then
			wlanconfig $created destroy 2>/dev/null
		fi
	}

	scan_brcm()
	{
		if_exists=$(ifconfig | grep wl0)
		is_disabled=$(uci get wireless.wl0.disabled)
		if [ -z "$if_exists" ] || [ "$is_disabled" = 1 ] ; then
			wl up
			ifconfig wl0 up
		fi
		sleep 4

		iwinfo wl0 scan
		if [ -z "$if_exists" ] ; then
			ifconfig wl0 down
		fi
	}

	scan_mac80211()
	{
		radio_disabled1=$(uci get wireless.@wifi-device[0].disabled 2>/dev/null)
		radio_disabled2=$(uci get wireless.@wifi-device[1].disabled 2>/dev/null)
		g_sta=""
		a_sta=""
		iflist=$(iwinfo | awk '$0 ~ /^[a-z]/ { print $1 ; }' )
		for i in $iflist ; do
			i_info=$( iwinfo "$i" info 2>/dev/null )
			is_sta=$( printf "$i_info\n" | grep "Mode: *Client" )
			if [ -n "$is_sta" ] ; then
				is_g=$(   printf "$i_info\n" | egrep "802.11((b)|(bg)|(gb)|(g)|(gn)|(bgn))" )
				is_a=$(   printf "$i_info\n" | egrep "802.11an" )
				if [ -n "$is_g" ] ; then
					g_sta="$i"
				elif [ -n "$is_a" ] ; then
					a_sta="$i"
				fi
			fi
		done	


		test_ifs="$g_sta"
		if [ -z "$g_sta" ] || [ "$radio_disabled1" = "1" ] || [ "$radio_disabled2" = "1" ]  ; then
			g_sta=""
			test_ifs="phy0"
		fi

		if [ `uci show wireless | grep wifi-device | wc -l`"" = "2" ] && [ -e "/sys/class/ieee80211/phy1" ] && [ ! `uci get wireless.@wifi-device[0].hwmode`"" = `uci get wireless.@wifi-device[1].hwmode`""  ] ; then
			phy0_is_g=$(iw phy0 info | grep " 2.*MHz")
			g_phy="phy0"
			a_phy="phy1"
			if [ -z "$phy0_is_g" ] ; then
				g_phy="phy1"
				a_phy="phy0"
			fi
			if [ -z "$g_sta" ] ; then
				test_ifs="$g_phy"
			fi
			if [ -z "$a_sta" ] || [ "$radio_disabled1" = "1" ] || [ "$radio_disabled2" = "1" ] ; then
				test_ifs="$test_ifs $a_phy"
			else
				test_ifs="$test_ifs $a_sta"
			fi
		fi

		for if in $test_ifs ; do
			iwinfo "$if" scan
		done

	}
