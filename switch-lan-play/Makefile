#
# Copyright (C) 2009-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=switch-lan-play
PKG_VERSION:=0.2.3
PKG_RELEASE:=4

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=null
PKG_SOURCE_URL:=https://github.com/spacemeowx2/switch-lan-play.git
PKG_MIRROR_HASH:=skip
#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE.TXT

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_BINARY_SUBDIR := build-openwrt

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Lan-play
	DEPENDS:=+libpcap +libpthread +libstdcpp +libatomic @!USE_UCLIBC
	TITLE:=Switch Lan Play Client
endef

define Package/switch-lan-play/conffiles
/etc/config/switchlanplay
endef

define Package/$(PKG_NAME)/description
  Make you and your friends play games like in a LAN.
endef

#define Build/Prepare
#	mkdir -p $(PKG_BUILD_DIR)
#	$(CP) ./$(PKG_NAME)/* $(PKG_BUILD_DIR)/
#endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build-openwrt/src/lan-play $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/switchlanplay.config $(1)/etc/config/switchlanplay
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/switchlanplay.init $(1)/etc/init.d/switchlanplay
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
