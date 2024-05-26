#
# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-LingTiGameAcc
PKG_VERSION:=20200726
PKG_RELEASE:=6
PKG_MAINTAINER:=eSir Playground <https://github.com/esirplayground/luci-app-LingTiGameAcc>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	CATEGORY:=eSir Playground
	SUBMENU:=2. GameAcc
	TITLE:=LuCI support for LingTiGameAcc
	PKGARCH:=all
	DEPENDS:=+LingTiGameAcc
endef

define Package/$(PKG_NAME)/description
LuCI Support of Simple Switch to turn LingTiGameAcc ON/OFF
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/lingti $(1)/etc/config/lingti
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/lingti_luci $(1)/etc/init.d/lingti_luci

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_CONF) ./root/etc/uci-defaults/* $(1)/etc/uci-defaults
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/lingti.po $(1)/usr/lib/lua/luci/i18n/lingti.zh-cn.lmo
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
	/etc/init.d/lingti_luci enable >/dev/null 2>&1
	chmod a+x $${IPKG_INSTROOT}/etc/init.d/lingti_luci >/dev/null 2>&1
exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
     /etc/init.d/lingti_luci disable
     /etc/init.d/lingti_luci stop
fi
exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
