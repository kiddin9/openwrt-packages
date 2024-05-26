include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-minieap
PKG_VERSION=1.0.2
PKG_RELEASE:=15

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-minieap
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=minieap 802.1X Client for LuCI
	PKGARCH:=all
endef

define Package/luci-app-minieap/description
	This package contains LuCI configuration pages for 8021xclient.
endef

define Package/luci-app-minieap/conffiles
	/etc/config/minieap
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-minieap/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/minieap
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/minieap.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_CONF) ./files/root/etc/config/minieap $(1)/etc/config/minieap
	$(INSTALL_BIN) ./files/root/etc/init.d/minieap $(1)/etc/init.d/minieap
	$(INSTALL_BIN) ./files/root/usr/sbin/minieap-conver $(1)/usr/sbin/minieap-conver
	$(INSTALL_BIN) ./files/root/usr/sbin/minieap-ping $(1)/usr/sbin/minieap-ping
	$(INSTALL_DATA) ./files/luci/model/cbi/minieap/general.lua $(1)/usr/lib/lua/luci/model/cbi/minieap/general.lua
	$(INSTALL_DATA) ./files/luci/model/cbi/minieap/customfile.lua $(1)/usr/lib/lua/luci/model/cbi/minieap/customfile.lua
	$(INSTALL_DATA) ./files/luci/model/cbi/minieap/log.lua $(1)/usr/lib/lua/luci/model/cbi/minieap/log.lua
	$(INSTALL_DATA) ./files/luci/controller/minieap.lua $(1)/usr/lib/lua/luci/controller/minieap.lua
endef

$(eval $(call BuildPackage,luci-app-minieap))
