#
# Copyright (C) 2006,2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifidog-wiwiz
PKG_VERSION:=20130917
PKG_RELEASE=$(PKG_SOURCE_VERSION)


PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/wifidog-wiwiz
  SUBMENU:=Portal
  SECTION:=net
  CATEGORY:=Wiwiz/PinPinWiFi
  DEPENDS:=+luci-app-eqos +dcc2-wiwiz-nossl +iptables-mod-extra +iptables-mod-ipopt +iptables-mod-nat-extra +libpthread +curl
  TITLE:=wifidog-wiwiz
  URL:=http://www.wiwiz.com
  MENU:=1
endef

define Package/wifidog-wiwiz/description
	Wifidog modified by Wiwiz.com
endef

define Package/wifidog-wiwiz/conffiles
/etc/wifidog.conf
endef

define Package/wifidog-wiwiz/config
	source "$(SOURCE)/Config.in"
endef

define Package/wifidog-wiwiz/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/init.d/wifidog $(1)/usr/bin/wifidog-init
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wifidog $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wdctl $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhttpd.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/wifidog.conf $(1)/etc/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/wifidog-msg.html $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wifidog.init $(1)/etc/init.d/wifidog

	$(INSTALL_DIR) $(1)/usr/local
	$(INSTALL_DIR) $(1)/usr/local/hsbuilder
	$(INSTALL_BIN) ./files/usr/local/hsbuilder/hsbuilder.sh $(1)/usr/local/hsbuilder/hsbuilder.sh
	$(INSTALL_BIN) ./files/usr/local/hsbuilder/hsbuilder_helper.sh $(1)/usr/local/hsbuilder/hsbuilder_helper.sh
	$(INSTALL_BIN) ./files/usr/local/hsbuilder/setspeed.sh $(1)/usr/local/hsbuilder/setspeed.sh
	$(INSTALL_BIN) ./files/usr/local/hsbuilder/wiwizroaming.sh $(1)/usr/local/hsbuilder/wiwizroaming.sh
	$(INSTALL_BIN) ./files/usr/local/hsbuilder/getmodel.sh $(1)/usr/local/hsbuilder/getmodel.sh
	$(INSTALL_DATA) ./files/usr/local/hsbuilder/hsbuilder.conf $(1)/usr/local/hsbuilder/hsbuilder.conf
	$(INSTALL_DATA) ./files/usr/local/hsbuilder/ver $(1)/usr/local/hsbuilder/ver

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/wiwiz.lua $(1)/usr/lib/lua/luci/controller/wiwiz.lua
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/wiwiz.lua $(1)/usr/lib/lua/luci/model/cbi/wiwiz.lua

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/wiwiz $(1)/etc/config/wiwiz

	$(INSTALL_DIR) $(1)/www
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) ./files/www/cgi-bin/mymac $(1)/www/cgi-bin/mymac
	$(INSTALL_BIN) ./files/www/cgi-bin/myip $(1)/www/cgi-bin/myip
	$(INSTALL_BIN) ./files/www/cgi-bin/showdevinfo $(1)/www/cgi-bin/showdevinfo
	$(INSTALL_DATA) ./files/www/index.html.wiwiz $(1)/www/index.html.wiwiz
	$(INSTALL_DATA) ./files/www/error.html.wiwiz $(1)/www/error.html.wiwiz
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/199-noredir $(1)/etc/uci-defaults/199-noredir
	
ifeq ($(CONFIG_NO_PORTAL),y)
	$(INSTALL_BIN) ./files/etc/uci-defaults/299-noportal $(1)/etc/uci-defaults/299-noportal
endif
endef

define Package/wifidog-wiwiz/postinst
#!/bin/sh
cp -f $${IPKG_INSTROOT}/www/index.html $${IPKG_INSTROOT}/www/index.html.org
cp -f $${IPKG_INSTROOT}/www/index.html.wiwiz $${IPKG_INSTROOT}/www/index.html
rm -f $${IPKG_INSTROOT}/www/index.html.wiwiz
cp -f $${IPKG_INSTROOT}/www/error.html.wiwiz $${IPKG_INSTROOT}/www/error.html
rm -f $${IPKG_INSTROOT}/www/error.html.wiwiz
endef

$(eval $(call BuildPackage,wifidog-wiwiz))

