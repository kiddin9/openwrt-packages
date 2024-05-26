include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-homebridge
PKG_VERSION:=0.1.0
PKG_RELEASE:=14
PKG_DATE:=20200311

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=lanxin Shang <shanglanxin@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for homebridge
	PKGARCH:=all
	DEPENDS:=+node
endef

define Package/$(PKG_NAME)/description
	LuCI Support for homebridge.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
mkdir $${IPKG_INSTROOT}/etc/homebridge/ >/dev/null 2>&1
exit 0
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/homebridge
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/homebridge
	$(INSTALL_DATA) ./files/luci/model/cbi/homebridge/*.lua $(1)/usr/lib/lua/luci/model/cbi/homebridge/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/homebridge
	$(INSTALL_DATA) ./files/luci/view/homebridge/*.htm $(1)/usr/lib/lua/luci/view/homebridge/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/root/etc/config/homebridge $(1)/etc/config/homebridge
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/homebridge $(1)/etc/init.d/homebridge
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/root/etc/uci-defaults/luci-homebridge $(1)/etc/uci-defaults/luci-homebridge
	
	$(INSTALL_DIR) $(1)/usr/share/homebridge
	$(INSTALL_BIN) ./files/root/usr/share/homebridge/*.sh $(1)/usr/share/homebridge/
	$(INSTALL_BIN) ./files/root/usr/share/homebridge/*.lua $(1)/usr/share/homebridge/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))