#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=airconnect
PKG_VERSION:=1.0.13
PKG_RELEASE:=6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_VERSION:=null
PKG_SOURCE_URL_FILE:=$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/philippe44/AirConnect/archive/
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/AirConnect-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=jjm2473 <jjm2473@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=AirConnect
  URL:=https://github.com/philippe44/AirConnect
endef

define Package/$(PKG_NAME)/description
 Use AirPlay to stream to UPnP/Sonos & Chromecast devices
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/airconnect
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/aircast-linux-$(ARCH)-static $(1)/usr/bin/aircast
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/airupnp-linux-$(ARCH)-static $(1)/usr/bin/airupnp
	$(INSTALL_CONF) ./files/airconnect.config $(1)/etc/config/airconnect
	$(INSTALL_BIN) ./files/airconnect.init $(1)/etc/init.d/airconnect
endef

$(eval $(call BuildPackage,airconnect))
