#!/bin/sh

# get data
get_data(){
	DATATYPE=$(uci -q get cellled.@device[0].data_type)
	case $DATATYPE in
		mm)
			PORT=$(uci -q get cellled.@device[0].device_mm)
			RSSI=$(mmcli -m ${PORT} -J | jsonfilter -e '@["modem"]["generic"]["signal-quality"]["value"]')
		;;
		qmi)
			PORT=$(uci -q get cellled.@device[0].device_qmi)
			QMICTL="qmicli -p -d $PORT"
			RSSIDB=$($QMICTL --nas-get-signal-info | awk -F [\'\:\ ] '/RSSI:/{print $4}')
			RSSI=$(echo $RSSIDB |awk '{printf "%d\n", (100*(1-(-51 - $1)/(-50 - -113)))}')
		;;
		uqmi)
			PORT=$(uci -q get cellled.@device[0].device_qmi)
			RSSIDB=$(uqmi -d ${PORT} --get-signal-info | jsonfilter -e '@["rssi"]')
			RSSI=$(echo $RSSIDB |awk '{printf "%d\n", (100*(1-(-51 - $1)/(-51 - -113)))}')
		;;
		serial)
			PORT=$(uci -q get cellled.@device[0].device)
			RSSI=$(gcom -d ${PORT} -s /etc/gcom/getstrength.gcom | awk -F [:,] '/CSQ:/{printf "%.0f\n", $2*100/31}')
		;;
	esac
}

# get rssi levels
get_led_level(){
        RSSI_MIN=$(uci -q get cellled.@rssi_led[$n].rssi_min)
        RSSI_MAX=$(uci -q get cellled.@rssi_led[$n].rssi_max)
}

# set rgb light
set_led_rgb(){
        if [ $RSSI -ge $RSSI_MIN -a $RSSI -le $RSSI_MAX ]; then
              	LED_ON=$(echo $RSSI_MIN $RSSI_MAX $RSSI | awk '{printf "%.0f\n", (255/($2-$1)*($3-$1))}')
		STATE=true
	else
		LED_ON=0
		STATE=false
	fi
}

# set linear light
set_led_linear(){
        if [ $RSSI -ge $RSSI_MIN -a $RSSI -lt $RSSI_MAX ]; then
                STATE=true
        elif [ $RSSI -ge $RSSI_MAX ]; then
                STATE=true
        elif [ $RSSI -lt $RSSI_MIN ]; then
                STATE=false
        else
                STATE=false
        fi
}

# set linear led level
if_linear(){
	LED=$(uci -q get cellled.@rssi_led[$n].led)
	get_led_level
	set_led_linear
	if [ $STATE = true -a $LED ]; then
		LED_ON=255
		echo $LED_ON > /sys/class/leds/$LED/brightness
	else
		LED_ON=0
		echo $LED_ON > /sys/class/leds/$LED/brightness
	fi

}

# set grb led level
if_rgb(){
	PWM=$(uci -q get cellled.@device[0].pwm_mode)
	LED_R=$(uci -q get cellled.@device[0].red_led)
	LED_G=$(uci -q get cellled.@device[0].green_led)
	LED_B=$(uci -q get cellled.@device[0].blue_led)
	case $TYPE in
		poor)
			get_led_level
			set_led_rgb
			if [ $STATE = true ]; then
				R=255
				G=0
				if [ "$PWM" = "1" ]; then
					B=$((255-$LED_ON))
				else
					B=255
				fi
			fi
		;;
		bad)
			get_led_level
			set_led_rgb
			if [ $STATE = true ]; then
				R=255
				if [ "$PWM" = "1" ]; then
					G=$LED_ON
				else
					G=0
				fi
				B=0
			fi
		;;
		fair)
			get_led_level
			set_led_rgb
			if [ $STATE = true ]; then
				if [ "$PWM" = "1" ]; then
					R=$((255-$LED_ON))
				else
					R=255
				fi
				G=255
				B=0
			fi
		;;
		good|best|excellend)
			get_led_level
			set_led_rgb
			if [ $STATE = true ]; then
				R=0
				G=255
				B=0
			fi
		;;
	esac
	if [ ! $R ]; then R=0; fi
	if [ ! $G ]; then G=0; fi
	if [ ! $B ]; then B=0; fi
}

# select type led (rgb or linear)
select_led(){
	if [ "$RGB_LED" = "1" ]; then
		TYPE=$(uci -q get cellled.@rssi_led[$n].type)
		if_rgb
	else
		if_linear
	fi
}

# get param
get_param(){
	RSSI=$RSSI
	if [ $RSSI -lt 0 ]; then
		RSSI=0
	elif [ $RSSI -gt 100 ]; then
		RSSI=100
	fi
	LED_ON=0
	RGB_LED=$(uci -q get cellled.@device[0].rgb_led)
	SECTIONS=$(uci show cellled | awk -F [\]\[\@=] '/=rssi_led/{print $3}')
	TIMEOUT=$(uci -q get cellled.@device[0].timeout)
	if [ -z $RSSI ]; then
        	exit 2
	fi
}

get_data
get_param
for n in $SECTIONS; do
	select_led
done
if [ "$RGB_LED" = "1" -a $LED_R -a $LED_G -a $LED_B ]; then
	#echo "${LED_R}=${R} ${LED_G}=${G} ${LED_B}=${B}"
        echo $R > /sys/class/leds/$LED_R/brightness
        echo $G > /sys/class/leds/$LED_G/brightness
        echo $B > /sys/class/leds/$LED_B/brightness
fi

sleep $TIMEOUT
