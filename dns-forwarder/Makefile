#
# Copyright (C) 2015 OpenWrt-dist
# Copyright (C) 2015 Jian Chang <aa65535@live.com>
#
# Copyright (C) 2021 ImmortalWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dns-forwarder
PKG_VERSION:=1.2.1
PKG_RELEASE:=9

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aa65535/hev-dns-forwarder.git
PKG_SOURCE_DATE:=2017-07-21
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dns-forwarder
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Forwarding DNS queries on TCP transport
  URL:=https://github.com/aa65535/hev-dns-forwarder
endef

define Package/dns-forwarder/conffiles
/etc/config/dns-forwarder
endef

define Package/dns-forwarder/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/hev-dns-forwarder $(1)/usr/bin/dns-forwarder
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/dns-forwarder.config $(1)/etc/config/dns-forwarder
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dns-forwarder.init $(1)/etc/init.d/dns-forwarder
endef

$(eval $(call BuildPackage,dns-forwarder))
