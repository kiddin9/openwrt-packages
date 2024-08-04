#
# Copyright (C) 2023-2024 muink <https://github.com/muink>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

LUCI_NAME:=luci-app-packagesync

LUCI_TITLE:=LuCI Local software source
LUCI_DEPENDS:=+blockd +curl +getopt +rsync +bash +jsonfilter +ncat-full

LUCI_DESCRIPTION:=Used to build a local mirror feeds source on the router

define Package/$(LUCI_NAME)/conffiles
/etc/config/packagesync
endef

define Package/$(LUCI_NAME)/postinst
endef

define Package/$(LUCI_NAME)/prerm
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
