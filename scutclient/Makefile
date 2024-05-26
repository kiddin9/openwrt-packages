#
# Copyright (C) 2016-2018 SCUT Router Term
#
# This is free software, licensed under the GNU Affero General Public License v3.
# See /COPYING for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=scutclient
PKG_BASE_VERSION:=3.1.3
PKG_RELEASE:=28

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/scutclient/scutclient.git
PKG_SOURCE_DATE:=2021-11-26
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_VERSION:=$(PKG_BASE_VERSION)-$(PKG_SOURCE_DATE)-$(call version_abbrev,$(PKG_SOURCE_VERSION))

PKG_MAINTAINER:=Scutclient Project
PKG_LICENSE:=AGPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/scutclient
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Campus Network
  TITLE:=SCUT Dr.com client
  URL:=https://github.com/scutclient/scutclient
endef

define Package/scutclient/description
  Support SCUT private authentication protocol.
endef

define Package/scutclient/conffiles
/etc/config/scutclient
endef

define Package/scutclient/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/openwrt/files/scutclient.config $(1)/etc/config/scutclient
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/scutclient.init $(1)/etc/init.d/scutclient
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/scutclient.hotplug $(1)/etc/hotplug.d/iface/99-scutclient
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/scutclient $(1)/usr/bin
endef

$(eval $(call BuildPackage,scutclient))
