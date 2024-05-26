#
# Copyright (C) 2017-2019 Chen Minqiang <ptpt52@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for wizard
LUCI_DEPENDS:=
LUCI_PKGARCH:=all
PKG_NAME:=luci-app-wizard

PKG_MAINTAINER:=Chen Minqiang <ptpt52@gmail.com>
PKG_LICENSE:=GPLv3

define Package/luci-app-wizard/conffiles
/etc/config/wizard
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature