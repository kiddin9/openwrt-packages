#!/bin/bash -e
function sed_wrapper() {
    # if run in linux, use sed -i
    # if run in macos, use sed -i ''
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sed -i "$@"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        /usr/local/opt/gnu-sed/libexec/gnubin/sed -i "$@"
    fi
}

sed_wrapper '/luci.mk/ c\include $(TOPDIR)/feeds/luci/luci.mk' packages/luci-app-natmap/Makefile

# remove the last \
dep=${dep%\\}
if [[ $1 =~ '21.02'* ]]; then
    dep="$dep +ip6tables-mod-nat +iptables-mod-extra +iptables-mod-tproxy"
else
    dep="$dep +kmod-nft-tproxy"
fi
