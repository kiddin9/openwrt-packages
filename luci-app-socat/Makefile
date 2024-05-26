# Copyright (C) 2020 Lienol <lawlienol@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-socat

PKG_MAINTAINER:=Lienol <lawlienol@gmail.com>

LUCI_TITLE:=LuCI support for Socat
LUCI_DEPENDS:=+socat
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/config/socat
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
