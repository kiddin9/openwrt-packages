#
# Copyright 2019-2024 sirpdboy 
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

NAME:=parentcontrol
PKG_NAME:=luci-app-$(NAME)
PKG_LICENSE:=Apache-2.0

LUCI_TITLE:=LuCI support for Parent Control
LUCI_DEPENDS:=+iptables-mod-filter +kmod-ipt-filter
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/config/parentcontrol
endef
include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


