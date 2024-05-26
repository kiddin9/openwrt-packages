#!/bin/sh

# Check=$(python3 /usr/share/natter/natter.py --check-nat 2>&1 | grep -v "Checking" | grep 'NAT Type for')

script_file='/usr/share/natter/natter.py'
tmp_path=$(uci get natter.@base[0].log_path)
[ ! "$tmp_path" ] && tmp_path=/tmp/natter

mkdir -p $tmp_path
python3 $script_file --check-nat 2>&1 | grep -v "Checking" | grep 'NAT Type for' > $tmp_path/natter_nat_type.tmp
TCP=$(awk -F '[:]+' '/TCP/{print $2}' $tmp_path/natter_nat_type.tmp | sed 's/\[//g;s/\]//g')
UDP=$(awk -F '[:]+' '/UDP/{print $2}' $tmp_path/natter_nat_type.tmp | sed 's/\[//g;s/\]//g')
rm -f $tmp_path/natter_nat_type.tmp
[ ! "$TCP" ] && TCP="未知"
[ ! "$UDP" ] && UDP="未知"

echo "TCP:$TCP"
echo "UDP:$UDP"
