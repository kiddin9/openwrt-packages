#
# Copyright (C) 2015-2016 OpenWrt.org
# Copyright (C) 2024 xiaobao@linkease.com
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_ARCH_sunpanel:=$(ARCH)

PKG_NAME:=sunpanel
PKG_VERSION:=1.3.1
PKG_RELEASE:=5
PKG_SOURCE:=$(PKG_NAME)-binary-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/linkease/istore-packages/releases/download/prebuilt/
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-binary-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=SunPanel, NAS navigation panel.
	DEPENDS:=@(x86_64||aarch64||arm) +ubus +uci +bash
	URL:=https://sun-panel-doc.enianteam.com/
endef

define Package/$(PKG_NAME)/description
  Server, NAS navigation panel, Homepage, Browser homepage.
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/sunpanel
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	[ -f /etc/uci-defaults/sunpanel ] && /etc/uci-defaults/sunpanel && rm -f /etc/uci-defaults/sunpanel
fi
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config $(1)/usr/libexec/istorec $(1)/usr/share/sunpanel $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sunpanelbin.$(PKG_ARCH_sunpanel) $(1)/usr/sbin/sunpanelbin
	$(INSTALL_BIN) ./files/sunpanel.init $(1)/etc/init.d/sunpanel
	$(CP) ./files/sunpanel_conf.lua $(1)/usr/libexec/istorec/
	$(CP) ./files/conf.temp $(1)/usr/share/sunpanel/
	$(INSTALL_CONF) ./files/sunpanel.config $(1)/etc/config/sunpanel
	$(INSTALL_BIN) ./files/sunpanel.uci-default $(1)/etc/uci-defaults/sunpanel
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
