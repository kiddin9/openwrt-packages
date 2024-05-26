#
# Copyright (C) 2017-2019 Chen Minqiang <ptpt52@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-xwan
PKG_VERSION:=1.0.0
PKG_RELEASE:=4

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Chen Minqiang <ptpt52@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-xwan
	CATEGORY:=X
	SUBMENU:=Xwan
	TITLE:=LuCI Support for xwan
	PKGARCH:=all
	DEPENDS:=+kmod-macvlan +busybox +@BUSYBOX_CUSTOM +@BUSYBOX_CONFIG_VCONFIG +luci-compat
endef

define Package/luci-app-xwan/description
	LuCI Support for xwan.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-xwan/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi

if [ -z "$$IPKG_INSTROOT" ]; then
  ( . /etc/uci-defaults/40_luci-app-xwan )
  rm -f /etc/uci-defaults/40_luci-app-xwan
fi

exit 0
endef

define Package/luci-app-xwan/conffiles
/etc/config/xwan
endef

define Package/luci-app-xwan/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/xwan.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/xwan
	$(INSTALL_DATA) ./files/luci/model/cbi/xwan/*.lua $(1)/usr/lib/lua/luci/model/cbi/xwan/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/root/etc/config/xwan $(1)/etc/config/xwan
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/xwan $(1)/etc/init.d/xwan
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/root/etc/uci-defaults/40_luci-app-xwan $(1)/etc/uci-defaults/40_luci-app-xwan
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/*.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/usr/share/ucitrack
	$(INSTALL_DATA) ./root/usr/share/ucitrack/*.json $(1)/usr/share/ucitrack/
endef

$(eval $(call BuildPackage,luci-app-xwan))
