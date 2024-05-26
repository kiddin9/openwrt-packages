#
# Copyright (C) 2006,2008 OpenWrt.org
# Copyright (C) 2008 Technologies Coeus inc.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=wifidog
PKG_VERSION:=20090925
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= @SF/$(PKG_NAME)
PKG_MD5SUM:=

PKG_FIXUP = libtool

include $(INCLUDE_DIR)/package.mk

define Package/wifidog
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+kmod-ipt-extra +iptables-mod-extra +kmod-ipt-ipopt +iptables-mod-ipopt +kmod-ipt-nat +iptables-mod-nat +libpthread
  TITLE:=A wireless captive portal solution
  URL:=http://www.wifidog.org
endef

define Package/wifidog/description
	The Wifidog project is a complete and embeddable captive 
	portal solution for wireless community groups or individuals 
	who wish to open a free Hotspot while still preventing abuse 
	of their Internet connection.
endef

define Package/wifidog/conffiles
/etc/wifidog.conf
endef

MAKE_FLAGS += \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	all install

define Package/wifidog/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/init.d/wifidog $(1)/usr/bin/wifidog-init
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wifidog $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wdctl $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhttpd.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/wifidog.conf $(1)/etc/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/wifidog-msg.html $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/wifidog
endef

$(eval $(call BuildPackage,wifidog))
