include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-broadbandacc
PKG_VERSION:=3.8
PKG_RELEASE:=19

PKG_MAINTAINER:=Diciya <484154383@qq.com>
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
 
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-broadbandacc
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=broadband accelerate
	DEPENDS:=+luci-compat +jshn +wget
	PKGARCH:=all
endef

define Package/luci-app-broadbandacc/description
 Broadband uplink and downlink acceleration functions.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-broadbandacc/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/broadband
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d  

	$(INSTALL_BIN) ./files/root/etc/uci-defaults/luci-broadband $(1)/etc/uci-defaults/luci-broadband
	$(INSTALL_BIN) ./files/root/etc/hotplug.d/iface/99-broadband $(1)/etc/hotplug.d/iface/99-broadband
	$(INSTALL_DATA) ./files/luci/controller/broadband.lua $(1)/usr/lib/lua/luci/controller/broadband.lua
	$(INSTALL_DATA) ./files/luci/model/cbi/broadband.lua $(1)/usr/lib/lua/luci/model/cbi/broadband.lua
	$(INSTALL_DATA) ./files/luci/view/broadband/status.htm $(1)/usr/lib/lua/luci/view/broadband/status.htm
	$(INSTALL_DATA) ./files/luci/view/broadband/logview.htm $(1)/usr/lib/lua/luci/view/broadband/logview.htm
	$(INSTALL_DATA) ./files/luci/view/broadband/shopview.htm $(1)/usr/lib/lua/luci/view/broadband/shopview.htm
	$(INSTALL_DATA) ./files/luci/i18n/broadband_zh-cn.lmo $(1)/usr/lib/lua/luci/i18n/broadband.zh-cn.lmo
	$(INSTALL_BIN) ./files/root/usr/bin/broadband.sh $(1)/usr/bin/broadband.sh
	$(INSTALL_BIN) ./files/root/usr/share/rpcd/acl.d/luci-app-broadband.json $(1)/usr/share/rpcd/acl.d/luci-app-broadband.json
	$(INSTALL_CONF) ./files/root/etc/config/broadband $(1)/etc/config/broadband
	$(INSTALL_BIN) ./files/root/etc/init.d/broadband $(1)/etc/init.d/broadband
endef

define Package/luci-app-broadbandacc/postinst

endef

$(eval $(call BuildPackage,luci-app-broadbandacc))
