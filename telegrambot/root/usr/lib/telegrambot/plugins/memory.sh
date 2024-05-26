#!/bin/sh
echo -en "\`\`\` \n"
echo -en "$(cat /proc/meminfo | sed -n '1,5p')\`\`\`"
