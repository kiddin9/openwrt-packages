#!/bin/sh

ACTION=$1
VARIABLE=$2

case ${ACTION} in
	show) echo -en "\`\`\`$(uci show ${VARIABLE})\`\`\`" :;;
	get) echo -en " \`\`\`$(uci -q get ${VARIABLE})\`\`\`" :;;
	*) echo -en " Usage: */uci {show|get} [section]*" ;;
esac
