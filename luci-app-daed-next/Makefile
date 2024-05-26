# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-daed-next

LUCI_TITLE:=LuCI support for daed-next
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+daed-next +bash +luci-compat

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
