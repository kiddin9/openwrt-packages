include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-chinadns-ng
PKG_VERSION:=1.0
PKG_RELEASE:=7

include $(INCLUDE_DIR)/package.mk

define Create/uci-defaults
	( \
		echo '#!/bin/sh'; \
		echo 'uci -q batch <<-EOF >/dev/null'; \
		echo "	delete ucitrack.@$(1)[-1]"; \
		echo "	add ucitrack $(1)"; \
		echo "	set ucitrack.@$(1)[-1].init=$(1)"; \
		echo '	commit ucitrack'; \
		echo 'EOF'; \
		echo 'rm -f /tmp/luci-indexcache'; \
		echo 'exit 0'; \
	) > $(PKG_BUILD_DIR)/luci-$(1)
endef

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI support for chinadns-ng
	LUCI_DEPENDS:=+chinadns-ng
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/luasrc/i18n/*.po), \
		po2lmo $(po) ${CURDIR}/luasrc/i18n/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-chinadns-ng/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-chinadns-ng ) && rm -f /etc/uci-defaults/luci-chinadns-ng
	chmod 755 /etc/init.d/chinadns-ng >/dev/null 2>&1
	/etc/init.d/chinadns-ng enable >/dev/null 2>&1
fi
exit 0
endef

define Package/luci-app-chinadns-ng/postrm
#!/bin/sh
rm -f /tmp/luci-indexcache
exit 0
endef

define Package/$(PKG_NAME)/install
	$(call Create/uci-defaults,'chinadns-ng')
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DATA) root/usr/share/rpcd/acl.d/luci-app-chinadns-ng.json $(1)/usr/share/rpcd/acl.d/luci-app-chinadns-ng.json
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ${CURDIR}/luasrc/i18n/*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) luasrc/model/cbi/chinadns-ng.lua $(1)/usr/lib/lua/luci/model/cbi/chinadns-ng.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) luasrc/controller/chinadns-ng.lua $(1)/usr/lib/lua/luci/controller/chinadns-ng.lua
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luci-chinadns-ng $(1)/etc/uci-defaults/luci-chinadns-ng
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
