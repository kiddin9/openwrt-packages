#!/bin/sh
echo -en "Current DHCP leases:\n\`\`\`\n "
echo -en "Exp date   |        HWaddr     |   IP\n"
file='/tmp/dhcp.leases'
while IFS= read -r line <&3; do
  echo -en "$(date -d @$(printf '%s\n' "$line" | awk '{print $1}') +'%d.%m %H:%M') | "
  printf '%s' "$line" | awk '{print $2" | "$3}'
done 3< $file
echo -en "\`\`\`"
