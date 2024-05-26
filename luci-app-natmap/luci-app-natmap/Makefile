# This is free software, licensed under the Apache License, Version 2.0

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-natmap
PKG_VERSION:=1.5.0
PKG_RELEASE:=1

LUCI_TITLE:=LuCI Support for natmap
LUCI_DEPENDS:=+natmap +jq +curl +openssl-util +bash

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>

define Package/${PKG_NAME}/conffiles
/etc/config/natmap
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
