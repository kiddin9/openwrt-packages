#
# Copyright (C) 2020 tencentcloud <https://github.com/Tencent-Cloud-Plugins>
#
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-tencentddns
PKG_VERSION:=0.2.0
PKG_RELEASE:=11

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=tencentcloud <https://github.com/Tencent-Cloud-Plugins>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-tencentddns
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for tencentddns
	PKGARCH:=all
	DEPENDS:=+openssl-util +curl
endef

define Package/luci-app-tencentddns/description
	LuCI Support for TencentDDNS.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-tencentddns/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-tencentddns ]; then
		( . /etc/uci-defaults/luci-tencentddns ) && \
		rm -f /etc/uci-defaults/luci-tencentddns
	fi
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

define Package/luci-app-tencentddns/prerm
#!/bin/sh
/etc/init.d/tencentddns stop
exit 0
endef

define Package/luci-app-tencentddns/conffiles
/etc/config/tencentddns
endef

define Package/luci-app-tencentddns/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/tencentddns.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/tencentddns
	$(INSTALL_DATA) ./files/luci/model/cbi/*.lua $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/root/etc/config/tencentddns $(1)/etc/config/tencentddns
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/tencentddns $(1)/etc/init.d/tencentddns
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/root/etc/uci-defaults/luci-tencentddns $(1)/etc/uci-defaults/luci-tencentddns
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/root/usr/sbin/tencentddns $(1)/usr/sbin/tencentddns
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./files/root/etc/tencentddnsupload $(1)/etc/tencentddnsupload
endef

$(eval $(call BuildPackage,luci-app-tencentddns))
