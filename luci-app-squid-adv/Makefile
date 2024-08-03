# Copyright 2023- Douglas Orend <doug.orend2@gmail.com>
# This is free software, licensed under the Apache License, Version 2.0

include $(TOPDIR)/rules.mk

PKG_LICENSE:=Apache-2.0
PKG_NAME:=luci-app-squid-adv
PKG_VERSION:=2.0
PKG_RELEASE:=4
PKG_MAINTAINER:=Douglas Orend <doug.orend2@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-squid-adv
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Advanced LuCI support for Squid
	PKGARCH:=all
	#DEPENDS:=+squid +luci-base
endef

define Package/luci-app-squid-adv/description
	LuCI Support for Squid, complete with Transparent Proxy support for both HTTP and HTTPS!
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-squid-adv/install
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/squid-adv/
	$(INSTALL_DATA) ./htdocs/*.js $(1)/www/luci-static/resources/view/squid-adv/

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd/
	$(INSTALL_BIN) ./files/luci.squid-adv $(1)/usr/libexec/rpcd/

	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d/
	$(INSTALL_DATA) ./files/luci-menu.d.json $(1)/usr/share/luci/menu.d/luci-app-squid-adv.json

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/rpc-acl.d.json $(1)/usr/share/rpcd/acl.d/luci-app-squid-adv.json
endef

$(eval $(call BuildPackage,luci-app-squid-adv))
