include $(TOPDIR)/rules.mk


PKG_NAME:=luci-app-tencentcloud-cos
PKG_VERSION=1.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-tencentcloud-cos
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=COSFS Client for LuCI
	PKGARCH:=all
	DEPENDS=+vsftpd-alt
endef

define Package/luci-app-tencentcloud-cos/description
	This package contains LuCI configuration pages for 腾讯云COS.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-tencentcloud-cos/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller

	$(INSTALL_CONF) ./files/root/etc/config/cosclient $(1)/etc/config/cosclient
	$(INSTALL_CONF) ./files/root/etc/passwd-cosfs $(1)/etc/passwd-cosfs
	$(INSTALL_BIN) ./files/root/etc/init.d/cosclient $(1)/etc/init.d/cosclient
	$(INSTALL_BIN) ./files/root/etc/uploadData $(1)/etc/uploadData
	$(INSTALL_BIN) ./files/root/etc/uci-defaults/cosclient $(1)/etc/uci-defaults/cosclient
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/cosclient.lua $(1)/usr/lib/lua/luci/model/cbi/cosclient.lua
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/controller/cosclient.lua $(1)/usr/lib/lua/luci/controller/cosclient.lua
endef

$(eval $(call BuildPackage,luci-app-tencentcloud-cos))
