#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=airconnect
PKG_VERSION:=1.8.3
PKG_RELEASE=1

PKG_SOURCE:=AirConnect-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://github.com/philippe44/AirConnect/releases/download/$(PKG_VERSION)/
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/airconnect-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=sbwml <admin@cooluc.com>

ifeq ($(ARCH),arm)
  ARM_CPU_FEATURES:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))
  ifeq ($(ARM_CPU_FEATURES),)
    ARCH:=armv6
  endif
endif

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

define Build/Prepare
	unzip -q -d $(PKG_BUILD_DIR) $(DL_DIR)/AirConnect-$(PKG_VERSION).zip
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) ./files/airconnect.init $(1)/etc/init.d/airconnect
	$(INSTALL_CONF) ./files/airconnect.config $(1)/etc/config/airconnect
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/aircast-linux-$(ARCH)-static $(1)/usr/bin/aircast
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/airupnp-linux-$(ARCH)-static $(1)/usr/bin/airupnp
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
