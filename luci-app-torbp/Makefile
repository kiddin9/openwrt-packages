# Copyright 2018-2020 Alex D (https://gitlab.com/Nooblord/)
# Copyright 2022 ZeroChaos (https://github.com/zerolabnet/)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-torbp
PKG_VERSION:=1.0
PKG_RELEASE:=3
PKG_MAINTAINER:=ZeroChaos <dev@null.la>

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-torbp
	SECTION:=luci
	CATEGORY:=LuCI
	DEPENDS:=+tor +tor-geoip +obfs4proxy
	TITLE:=Tor bridges proxy
	MAINTAINER:=ZeroChaos <dev@null.la>
	URL:=https://zerolab.net
	PKGARCH:=all
endef

define Package/luci-app-torbp/description
Tor with SOCKS 5 proxy with a UI for the ability to add bridges
endef

define Package/luci-app-torbp/conffiles
/etc/config/torbp
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-torbp/install
	# Copy config
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/torbp $(1)/etc/config/torbp

	# Copy LuCI Description and ACL
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./files/usr/share/luci/menu.d/luci-app-torbp.json \
	$(1)/usr/share/luci/menu.d/luci-app-torbp.json
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/luci-app-torbp.json \
	$(1)/usr/share/rpcd/acl.d/luci-app-torbp.json

	# Copy web stuff
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/torbp.lua \
	$(1)/usr/lib/lua/luci/controller/torbp.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/torbp.lua \
	$(1)/usr/lib/lua/luci/model/cbi/torbp.lua

	# Copy translation
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/i18n/torbp.ru.lmo $(1)/usr/lib/lua/luci/i18n/
endef

define Package/luci-app-torbp/postinst
	#!/bin/sh
	if [ -z "$${IPKG_INSTROOT}" ]; then
		rm -f /tmp/luci-indexcache* 2>/dev/null
	fi
	exit 0
endef

$(eval $(call BuildPackage,luci-app-torbp))
