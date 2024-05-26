#
# Copyright 2019-2023 sirpdboy 
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

NAME:=autotimeset
PKG_NAME:=luci-app-$(NAME)
LUCI_TITLE:=LuCI support for Scheduled Time setting
LUCI_PKGARCH:=all



define Package/$(PKG_NAME)/conffiles
/etc/config/autotimeset
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

