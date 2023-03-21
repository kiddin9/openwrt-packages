#
# Copyright (C) 2019 mleaf.org
# 微信公众号【WiFi物联网】
#
# Copyright (C) 2021 ImmortalWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mwol
PKG_RELEASE:=22

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Mleaf/mwol.git
PKG_SOURCE_DATE:=2021-08-20
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=mleaf <mleaf90@gmail.com>

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mwol
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libmosquitto-ssl +libopenssl +libpthread +luci-lib-json
  TITLE:=MQTT Wake On Lan
  URL:=http://www.mleaf.org
endef

define Package/mwol/description
  Mwol is a project that uses mqtt to implement reverse proxy and
  wake up the computer.
endef

define Package/mwol/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mwol $(1)/usr/sbin/mwol

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) files/mwol.config $(1)/etc/config/mwol
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/mwol.init $(1)/etc/init.d/mwol

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) files/mwol_config_json $(1)/usr/sbin/mwol_config_json
	$(INSTALL_DIR) $(1)/usr/share/mwol/ssl
	$(CP) files/ssl/* $(1)/usr/share/mwol/ssl/
endef

$(eval $(call BuildPackage,mwol))
