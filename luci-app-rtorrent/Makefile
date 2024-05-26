#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=rTorrent LuCI web interface
LUCI_DEPENDS:=+rtorrent-rpc +luaexpat +luasocket +luasec +screen

PKG_LICENSE:=GPLv3

define Package//luci-app-rtorrent/conffiles
	/etc/config/rtorrent
	/etc/rtorrent.conf
endef

define Package/luci-app-rtorrent/postinst
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
endef

define Package/luci-app-rtorrent/postrm
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
