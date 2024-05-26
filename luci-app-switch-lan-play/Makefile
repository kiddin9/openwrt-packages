#
# Copyright (C) 2008-2015 The LuCI Team <luci@lists.subsignal.org>
# Copyright (C) 2018 @skylovebeauty <skylove@qq.com>
# Copyright (C) 2020 Kenneth Kasilag <kenneth@kasilag.me>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-switch-lan-play
PKG_VERSION:=0.0.3
PKG_RELEASE:=3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

LUA_LIBRARYDIR = /usr/lib/lua
LUCI_LIBRARYDIR = $(LUA_LIBRARYDIR)/luci

define Package/luci-app-switch-lan-play
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	DEPENDS:= +switch-lan-play
	TITLE:=luci-app-switch-lan-play
	PKGARCH:=all
endef

define Package/luci-app-switch-lan-play/description
	 LuCI web-interface for Switch Lan Play Client
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./* $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)$(LUCI_LIBRARYDIR)
	cp -pR $(PKG_BUILD_DIR)/luasrc/* $(1)$(LUCI_LIBRARYDIR)/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d/
	cp -pR $(PKG_BUILD_DIR)/files/luci-app-switch-lan-play.json $(1)/usr/share/rpcd/acl.d/luci-app-switch-lan-play.json
endef

define Package/$(PKG_NAME)/postinst
[ -n "$${IPKG_INSTROOT}" ] || {$(foreach script,$(LUCI_DEFAULTS),
	(. /etc/uci-defaults/$(script)) && rm -f /etc/uci-defaults/$(script))
	rm -f /tmp/luci-indexcache
	rm -rf /tmp/luci-modulecache/
	killall -HUP rpcd 2>/dev/null
	exit 0
}
endef

$(eval $(call BuildPackage,luci-app-switch-lan-play))
