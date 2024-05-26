#!/usr/bin/env awk
###############################################################
#parsing site_survey result to config file change it for need #
###############################################################
#Cell 01 - Address: xx:xx:xx:xx:xx:xx
#          ESSID: "TP-LINK_"
#          Mode: Master  Channel: 6
#          Signal: -68 dBm  Quality: 42/70
#          Encryption: mixed WPA/WPA2 PSK (CCMP) | none
###############################################################
#https://www.gnu.org/software/gawk/manual/html_node/Index.html
#/uci_config_file
#config wifi-scan
#        option wep '0'
#        option wpa '3'
#        option enc 'psk2'
#        option seen 'time_stamp'
#        option bssid 'xx:xx:xx:xx:xx:xx'
#        option ssid 'TP-LINK_'
#        option mode 'Master'
#        option channel '6'
#        option band 'G'
#        option signal '-68'
#        option quality '42'
#        option quality_max '70'
#        option percent '70'
#        option encryption 'mixed WPA/WPA2 PSK'
#        option ciphers 'ccmp'
#/^$/ {print "\n"; next} 1
#/^$/ {N}
#/^\s*$/ {next;}
#read var from outer[minipercent]
#awk -v awk -v abandfirst="${a_band_first}" -v minipercent="${scanpercent}" -v time_stamp="${_time}" -f /root/awk ..
BEGIN{
	counter=0
}
/^Cell/ {
	delete opt
	delete val
	skip_weak=1
	CONVFMT = "%3"
	strength_order=0
	band_order=0
	i=0
	opt[i] = "bssid"
	val[i++] = gensub(/^Cell.*Address: ([0-9a-fA-F:]+).*?$/,"\\1", "g", $0)
}
/^[[:space:]]*ESSID:/ {
	opt[i] = "ssid"
	_val = gensub(/^[[:space:]]*ESSID: \"(.*)\"$/, "\\1", "g", $0)
	#fix charactor for config file, by replace to '\''
	val[i++] = gensub(/'/, "'\\''", "g", _val)
}
/^[[:space:]]*Mode:/ {
	opt[i] = "mode"
	val[i++] = gensub(/^.*Mode: ([^ ]*).*?$/, "\\1", "g", $0)
	opt[i] = "channel"
	val[i++] = gensub(/^.*Channel: ([0-9]+).*?$/, "\\1", "g", $0)
	_ch=val[i-1] + 0
	opt[i] = "band"
	val[i++] = _ch > 30 ? "A" : "G"
	if (abandfirst != 0) band_order = val[i-1] == "A" ? 1 : 0
	#A
	#HT40+:[36, 44, 52, 60, 100, 108, 116, 124, 132, 140, 149, 157]
	#HT40-:[40, 48, 56, 64, 104, 112, 120, 128, 136, 144, 153, 161]
	#VHT40:[36, 44, 52, 60, 100, 108, 116, 124, 132, 140, 149, 157]
	#VHT80:[36, 52, 100, 116, 132, 149]
	#VHT160:[36, 100]
	#G
	#
}
/^[[:space:]]*Signal:/ {
	#dBm
	opt[i] = "signal"	
	val[i++] = gensub(/^[[:space:]]*Signal: (-[0-9]*).*?$/, "\\1", "g", $0)

	_val = gensub(/^.*Quality: ([^ ]*)$/, "\\1", "g", $0)
	split(_val, qs, "/")
	qs[1] = qs[1] != "" ? qs[1] : 0
	qs[2] = qs[2] != "" ? qs[2] : 100

	#%
	opt[i] = "quality"
	val[i++] = qs[1]
	opt[i] = "quality_max"
	val[i++] = qs[2]

	#%
	opt[i] = "percent"
	_val = qs[1] + 0 > 0 ? int(100 / qs[2] * qs[1]) : 0
	val[i++] = _val > 100 ? "100" : _val
	strength_order = val[i-1] + 0
	skip_weak = strength_order < minipercent + 0 ? 1 : 0
}
/^[[:space:]]*Encryption:/ {
	opt[i] = "encryption"
#	val[i++] = gensub(/^[[:space:]]*Encryption: (.*) \(.*$/, "\\1", "g", $0)
	val[i++] = gensub(/^[[:space:]]*Encryption: (.*)$/, "\\1", "g", $0)
	_val = val[i-1]

	opt[i] = "ciphers"
	val[i++] = gensub(/^.*\((.*)\).*?$/, "\\1", "g", tolower(_val))

	opt[i] = "wep"
	val[i++] = index(_val, "WEP") ? 1 : 0
	opt[i] = "wpa"
	val[i++] = index(_val, "mixed WPA/WPA2") != 0 ? 3 : ( index(_val, "WPA") != 0 ? 2 : 0)

	_enc = "psk2"
	opt[i] = "enc"
	val[i++] = index(_val, "WPA2 PSK") != 0 ? _enc : (index(_val, "WPA PSK") != 0 ? "psk" : (index(_val, "WEP") !=0 ? "wep" : (index(_val, "none") != 0 ? "none" : _val )))
	opt[i] = "seen"
	val[i++] = time_stamp
########output########
	if (!skip_weak) {
		counter++
		printf("config wifi-scan '%d%03d%d%04d'\n" ,band_order ,strength_order ,systime(), 10000 * rand())
		for (i in opt) if (val[i] != "") print "\toption", opt[i], "'"val[i]"'"
		print "\n"
	}
}
END {
	exit counter
}
