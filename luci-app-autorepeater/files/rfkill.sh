#!/bin/sh
#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
#.Christian Schoenebeck <tank dot dr at gmail dot com>
. /usr/lib/autorepeater/autorepeater_functions.sh

device="all"
config_load wireless
unset disabled
config_foreach load_wireless wifi-iface
reload_wifi
set_state $str_led_state
logger rfkill event triggled by switch $changeto $str_led_state
