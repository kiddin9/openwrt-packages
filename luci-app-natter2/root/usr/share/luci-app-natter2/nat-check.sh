#!/bin/sh

script_file='/usr/share/natter2/natter-check/natter-check.py'
natter2_nat_type_file="/tmp/natter2_nat_type"
tmp_natter2_nat_type_file="/tmp/tmp_natter2_nat_type"

rm -f $natter2_nat_type_file
rm -f $tmp_natter2_nat_type_file

$(which python) $script_file | egrep 'Checking TCP|Checking UDP' > $tmp_natter2_nat_type_file
TCP=$(awk -F '[:]+' '/TCP/{print $2}' $tmp_natter2_nat_type_file | sed 's/\[//g;s/\]//g')
UDP=$(awk -F '[:]+' '/UDP/{print $2}' $tmp_natter2_nat_type_file | sed 's/\[//g;s/\]//g')

[ ! "$TCP" ] && TCP="未知"
[ ! "$UDP" ] && UDP="未知"

function NAT_Type() {
	case $1 in
	0)
		echo "Public Network"
	;;
	1)
		echo "Full Cone"
	;;
	2)
		echo "Restricted Cone"
	;;
	3)
		echo "Port Restricted Cone"
	;;
	4)	
		echo "Symmetric"
	;;
	esac
}
echo "TCP: NAT $TCP | $(NAT_Type $TCP)" > $natter2_nat_type_file
echo "UDP: NAT $UDP | $(NAT_Type $UDP)" >> $natter2_nat_type_file

rm -f $tmp_natter2_nat_type_file