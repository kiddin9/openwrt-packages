#
# Copyright (C) 2016 Nikil Mehta <nikil.mehta@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nload
PKG_VERSION:=0.7.4
PKG_RELEASE:=2

PKG_MAINTAINER:=Konstantine Shevlakov <shevlakov@132lan.ru>
PKG_LICENSE:=LICENSE
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rolandriegel/nload.git
PKG_SOURCE_VERSION:=null

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)


PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Real time network traffic monitor for the text console
  URL:=https://github.com/rolandriegel/nload
  DEPENDS:=+libncurses +libstdcpp
endef

define Package/$(PKG_NAME)/description
	nload is a console application which monitors network traffic and bandwidth usage in real time.
	It visualizes the in- and outgoing traffic using two graphs and provides additional info like total amount of transfered data and min/max network usage.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/nload $(1)/usr/bin/
endef

$(eval $(call BuildPackage,nload))
