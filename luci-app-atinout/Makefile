#
# Copyright 2022-2023 Rafał Wabik - IceG - From eko.one.pl forum
#
# Licensed to the GNU General Public License v3.0.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-atinout
LUCI_TITLE:=LuCI JS Support for AT commands
MAINTAINER:=Rafał Wabik <4Rafal@gmail.com>
LUCI_DESCRIPTION:=LuCI JS interface for the atinout.
LUCI_DEPENDS:=+atinout
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/atcommands.user
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
