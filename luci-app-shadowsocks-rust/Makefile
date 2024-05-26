#
# Copyright (C) 2016-2018 Jian Chang <aa65535@live.com>
#               2017-2023 honwen https://github.com/honwen
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-shadowsocks

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=honwen <https://github.com/honwen>

LUCI_TITLE:=LuCI Support for shadowsocks-rust
LUCI_DEPENDS:=+iptables +ipset +curl +ip +iptables-mod-tproxy
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/config/shadowsocks
endef

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-shadowsocks ]; then
		( . /etc/uci-defaults/luci-shadowsocks ) && \
		rm -f /etc/uci-defaults/luci-shadowsocks
	fi
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature
