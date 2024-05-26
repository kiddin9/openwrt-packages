#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=speedtestpp
PKG_RELEASE:=3
PKG_VERSION:=1.14

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/taganaka/SpeedTest.git
PKG_SOURCE_VERSION:=null

PKG_MAINTAINER:=Konstantine Shevlakov <shevlyakov@132lan.ru>
PKG_LICENSE:=MIT

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Yet another unofficial speedtest.net client cli interface
  DEPENDS:=+libcurl +libxml2 +libopenssl +libstdcpp
  URL:=https://github.com/taganaka/SpeedTest
endef

CMAKE_OPTIONS += \
		 -DCMAKE_BUILD_TYPE=Release

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) \
		$(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/speedtestpp \
		$(1)/usr/bin
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
