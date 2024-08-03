#!/bin/bash
# dependent: bash rgmac getopt
#
# Interface MAC changer for Openwrt
# Author: muink
# Github: https://github.com/muink/luci-app-change-mac
#

# Init
MACPOOL=Mpool

# Get options
GETOPT=$(getopt -n $(basename $0) -o es:t:d -l assign:,device:,restore,help -- "$@")
[ $? -ne 0 ] && >&2 echo -e "\tUse the --help option get help" && exit 1
eval set -- "$GETOPT"
OPTIONS=$(sed "s| '[^']*'||g; s| -- .+$||; s| --$||" <<< "$GETOPT")

# Duplicate options
for ru in --help\|--help -d\|--restore -e\|-e -s\|--assign -t\|--device; do
  eval "grep -qE \" ${ru%|*}[ .+]* ($ru)| ${ru#*|}[ .+]* ($ru)\" <<< \"\$OPTIONS\" && >&2 echo \"\$(basename \$0): Option '\$ru' option is repeated\" && exit 1"
done
# Independent options
for ru in --help\|--help -d\|--restore; do
  eval "grep -qE \"^ ($ru) .+|.+ ($ru) .+|.+ ($ru) *\$\" <<< \"\$OPTIONS\" && >&2 echo \"\$(basename \$0): Option '\$(sed -E \"s,^.*($ru).*\$,\\1,\" <<< \"\$OPTIONS\")' cannot be used with other options\" && exit 1"
done
# Conflicting options
echo "$OPTIONS" | grep -E " (-s|--assign)\b" | grep -E " (-t|--device)\b" >/dev/null && >&2 echo "$(basename $0): Option '-s|--assign' cannot be used with option '-t|--device'" && exit 1



# Sub function
_help() {
printf "\n\
Usage: change-mac.sh [OPTION]... <INTERFACE>...\n\
Interface MAC changer for Openwrt\n\
\n\
  change-mac.sh eth0                    -- Use Locally administered address for 'eth0'\n\
  change-mac.sh eth1 eth2               -- MAC address is completely randomized\n\
  change-mac.sh -e eth1 eth2            -- MAC address is sequence randomization\n\
  change-mac.sh -t console:Sony eth0    -- Generate MAC address(Sony PS)\n\
\n\
Options:\n\
  -e                                    -- Sequence randomization\n\
  -s, --assign <xx:xx:xx>               -- Specify OUI manually\n\
  -t, --device <VendorType:NameID>      -- Use IEEE public OUI\n\
  -d, --restore                         -- Restore MAC address\n\
  --help                                -- Returns help info\n\
\n\
OptFormat:\n\
  <VendorType:NameID>    Valid: Please use 'rgmac -l[VendorType]' to get the reference
\n"
}

# rev <string>
rev() {
local string
local line
local timeout=20
if [ "$1" == "" ]; then
  while read -r -t$timeout line; do
    sed -e 'G;:1' -e 's/\(.\)\(.*\n\)/\2\1/;t1' -e 's/.//' <<< "$line"
  done
else
  string="$1"
  sed -e 'G;:1' -e 's/\(.\)\(.*\n\)/\2\1/;t1' -e 's/.//' <<< "$string"
fi
}

# mac_pool <Array> <Type> [Amount]
mac_pool() {
local pool=$1; shift
local type=$1; shift
local amount=$[ $1 + 0 ]
[ "$amount" -gt "0" ] && ((amount--))


if [ "$MODE" == "sequence" ]; then
  local mac=`rgmac -uac $type`
  [ "$?" == "1" ] && exit 1
  local nic=$[ 0x${mac: -8:2}${mac: -5:2}${mac: -2} -$amount ]
  [ "$nic" -lt "0" ] && nic=0

  for i in $(seq 0 $amount); do
    ((nic++))
    eval "${pool}[$i]=${mac:0:9}$(rev "000000$( printf %x $[ $nic & 0xFFFFFF ] )" | cut -c1-6 | rev | tr 'a-f' 'A-F' | sed -E 's|^(..)(..)(..)$|\1:\2:\3|')"
  done
else
  for i in $(seq 0 $amount); do
    eval "${pool}[$i]=$(rgmac -uac $type)"
    [ "$?" == "1" ] && exit 1
  done
fi
}



# Main
# Get options
while [ -n "$1" ]; do
  case "$1" in
    --help)
      _help
      exit
    ;;
    -e)
      MODE=sequence
    ;;
    -s|--assign)
      TYPE="$(sed -En "/^[0-f]{2}(:[0-f]{2}){2}$/ {s|^([0-f]{2}(:[0-f]{2}){2})$|-s\1|; p}" <<< "$2")"
      [ -z "$TYPE" ] && >&2 echo -e "$(basename $0): Option '$1' requires a valid argument\n\tUse the --help option get help" && exit 1
      shift
    ;;
    -t|--type)
      TYPE="$(sed -En "/^[^:]+:[^:]+$/ {s|^([^:]+:[^:]+)$|-t\1|; p}" <<< "$2")"
      [ -z "$TYPE" ] && >&2 echo -e "$(basename $0): Option '$1' requires a valid argument\n\tUse the --help option get help" && exit 1
      shift
    ;;
    -d|--restore)
      RESTORE=true
    ;;
    --)
      shift
      break
    ;;
    *)
      >&2 echo -e "$(basename $0): '$1' is not an option\n\tUse the --help option get help"
      exit 1
    ;;
  esac
  shift
done

# Get parameters
[ "$#" -eq "0" ] && >&2 echo -e "$(basename $0): No valid interfaces\n\tUse the --help option get help" && exit 1
_err=0
for _nic in "$@"; do
  [ "$_nic" == "lo" ] && >&2 echo -e "$(basename $0): Interface 'lo' is unvalid" && ((_err++))
  [ "$(ip link | grep " ${_nic}:")" == "" ] && >&2 echo -e "$(basename $0): Interface '$_nic' is unvalid" && ((_err++))
done
[ "$_err" -gt "0" ] && exit 1 || unset _err

# Filling pool
if [ -z "$RESTORE" ]; then
  mac_pool $MACPOOL "$TYPE" $#
fi

# Set
_count=0
for _nic in "$@"; do
  #single
  _section=$(uci show network | sed -En "/@device\[.*\]\.name='$_nic'/ {s|\.name=.*$|| p}")
  if [ -z "$RESTORE" ]; then
    [ "$_section" == "" ] && _section="network.$(uci add network device)" && uci set ${_section}.name="$_nic"
    eval "uci set ${_section}.macaddr=$(echo \"\${$MACPOOL[$_count]}\")"
  else
    [ "$_section" == "" ] || uci delete $_section
  fi
  ((_count++))
done
uci commit network
/etc/init.d/network reload

echo All Done!
