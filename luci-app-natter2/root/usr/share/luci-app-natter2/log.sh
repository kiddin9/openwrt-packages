#!/bin/sh

log_path=$(uci get natter2.@base[0].tmp_path 2> /dev/null)

for i in $(ls -1 ${log_path} | grep natter2 | grep .log)
do
	case $1 in
	print)
		echo -e "\n======> $i <======"
		tail -n 30 ${log_path}/$i 2> /dev/null
		echo -e "======> END of $i <======"
	;;
	del)
		echo > ${log_path}/$i
	;;
	esac
done

exit 0
