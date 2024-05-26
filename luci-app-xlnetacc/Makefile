include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-xlnetacc
PKG_VERSION:=1.1
PKG_RELEASE:=30

PKG_LICENSE:=GPLv2
PKG_MAINTAINER:=Sense <sensec@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for XLNetAcc
	PKGARCH:=all
	DEPENDS:=+jshn +curl +openssl-util +luci-compat
endef

define Package/$(PKG_NAME)/description
	LuCI Support for XLNetAcc.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/xlnetacc
endef

define Build/Prepare
	chmod +x root/etc/init.d/xlnetacc root/usr/bin/* >/dev/null 2>&1
endef

define Package/luci-app-xlnetacc/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/
	cp -pR ./root/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/xlnetacc.po $(1)/usr/lib/lua/luci/i18n/xlnetacc.zh-cn.lmo
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
