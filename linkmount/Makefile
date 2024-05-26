#
# Copyright (C) 2017-2020 Ian Leonard <antonlacon@gmail.com>
# Copyright (C) 2018 Ted Hess <thess@kitschensync.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_ARCH_LINKEASE:=$(ARCH)

PKG_NAME:=linkmount
PKG_VERSION:=1.0.3
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-binary-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://fw0.koolcenter.com/binary/LinkEase/AutoUpgrade/linkmount/
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-binary-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=LinkMount - the file cloud
	URL:=https://www.linkease.com/
endef

define Package/$(PKG_NAME)/description
  LinkMount is used by LinkEase
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin/linkmount
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_ARCH_LINKEASE)/bin/linkmount_bin $(1)/usr/sbin/linkmount/linkmount_bin
	$(CP) $(PKG_BUILD_DIR)/$(PKG_ARCH_LINKEASE)/bin/lib $(1)/usr/sbin/linkmount/lib
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

