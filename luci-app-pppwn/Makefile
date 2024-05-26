# Copyright (C) 2022 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for PPPWN
LUCI_DEPENDS:=+pppwn-cpp
LUCI_PKGARCH:=all
PKG_NAME:=luci-app-pppwn

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
