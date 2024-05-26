# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=msd_lite
PKG_RELEASE:=22

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rozhuk-im/msd_lite.git
PKG_SOURCE_DATE:=2024-03-16
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Tianling Shen <cnsztl@immrotalwrt.org>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/msd_lite
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Program for IP TV streaming on the network via HTTP
  URL:=http://www.netlab.linkpc.net/wiki/ru:software:msd:lite
endef

define Package/msd_lite/description
  msd_lite - Multi stream daemon lite. The lightweight version of
  Multi Stream daemon (msd) Program for organizing IP TV streaming
  on the network via HTTP.
endef

define Package/msd_lite/conffiles
/etc/config/msd_lite
endef

CMAKE_OPTIONS+= -DCONFDIR=../etc/msd_lite

define Package/msd_lite/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/msd_lite $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/msd_lite
	$(CP) $(CURDIR)/files/msd_lite.sample $(1)/etc/msd_lite/msd_lite.conf.sample
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/msd_lite.config $(1)/etc/config/msd_lite
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/msd_lite.init $(1)/etc/init.d/msd_lite
endef

$(eval $(call BuildPackage,msd_lite))
