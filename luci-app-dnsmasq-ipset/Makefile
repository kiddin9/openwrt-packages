include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-dnsmasq-ipset
PKG_VERSION:=0.2.0
PKG_RELEASE:=10

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Qier LU <lvqier@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-dnsmasq-ipset
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for ipset feature of dnsmasq-full
	PKGARCH:=all
	DEPENDS:=+dnsmasq-full
endef

define Package/luci-app-dnsmasq-ipset/description
	LuCI Support for ipset feature of dnsmasq-full.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-dnsmasq-ipset/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-dnsmasq-ipset ]; then
		( . /etc/uci-defaults/luci-dnsmasq-ipset ) && \
		rm -f /etc/uci-defaults/luci-dnsmasq-ipset
	fi
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

define Package/luci-app-dnsmasq-ipset/conffiles
/etc/config/dnsmasq-ipset
endef


define Package/luci-app-dnsmasq-ipset/install
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view
	$(INSTALL_DATA) ./files/htdocs/luci-static/resources/view/*.js $(1)/www/luci-static/resources/view/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/root/usr/share/rpcd/acl.d/*.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./files/root/usr/share/luci/menu.d/*.json $(1)/usr/share/luci/menu.d/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/root/etc/config/dnsmasq-ipset $(1)/etc/config/dnsmasq-ipset
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/dnsmasq-ipset $(1)/etc/init.d/dnsmasq-ipset
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/root/etc/uci-defaults/luci-dnsmasq-ipset $(1)/etc/uci-defaults/luci-dnsmasq-ipset
endef

$(eval $(call BuildPackage,luci-app-dnsmasq-ipset))
