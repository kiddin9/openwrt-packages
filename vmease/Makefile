#
# Copyright (C) 2015-2016 OpenWrt.org
# Copyright (C) 2020 jjm2473@gmail.com
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_ARCH_VMEASE:=$(ARCH)

PKG_NAME:=vmease
PKG_VERSION:=0.5.1
PKG_RELEASE:=5
PKG_SOURCE:=$(PKG_NAME)-binary-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://fw0.koolcenter.com/binary/vmease/
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-binary-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=VmEase - webvirtcloud helper
	PKGARCH:=all
	URL:=https://doc.linkease.com/zh/guide/istoreos/software/webvirtcloud.html
endef

define Package/$(PKG_NAME)/description
  VmEase is a helper tool for libvirtd
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/vmease
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	[ -f /etc/uci-defaults/vmease ] && /etc/uci-defaults/vmease && rm -f /etc/uci-defaults/vmease
fi
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/vmeasedaemon.$(PKG_ARCH_VMEASE) $(1)/usr/sbin/vmeasedaemon
	$(INSTALL_BIN) ./files/vmease.init $(1)/etc/init.d/vmease
	$(INSTALL_BIN) ./files/vmease.uci-default $(1)/etc/uci-defaults/vmease
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

