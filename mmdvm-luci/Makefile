#
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/version.mk

PKG_NAME:=mmdvm-luci
PKG_VERSION:=1.2.0
PKG_RELEASE:=6
GIT_REVISION:=$(shell git rev-parse --short HEAD)
PKG_REVISION:=$(PKG_VERSION)-$(PKG_RELEASE)-$(GIT_REVISION)
# PKG_BUILD_DEPENDS += $(LUCI_BUILD_DEPENDS)
PKG_BUILD_DEPENDS:=
PKG_CONFIG_DEPENDS += CONFIG_LUCI_SRCDIET CONFIG_LUCI_JSMIN CONFIG_LUCI_CSSTIDY
# PKG_FILE_DEPENDS:=
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Michael BD7MQB <bd7mqb@qq.com>

include $(INCLUDE_DIR)/package.mk

HTDOCS = /www
LUA_LIBRARYDIR = /usr/lib/lua
LUCI_LIBRARYDIR = $(LUA_LIBRARYDIR)/luci

LUCI_LANGUAGES:=$(sort $(filter-out templates,$(notdir $(wildcard ./luci-app-mmdvm/po/*))))
# Language code titles
LUCI_LANG.en=English
LUCI_LANG.zh-cn=中文 (Chinese)

define Package/${PKG_NAME}
	SECTION:=mmdvm
	CATEGORY:=MMDVM
	#SUBMENU:=Misc
	TITLE:=MMDVM's LuCI plugins.
	DEPENDS:=+mmdvm-host +libmmdvm +libubus-lua +libubox-lua +luci-compat
	#VERSION:=$(PKG_RELEASE)-$(REVISION)
endef

define Package/${PKG_NAME}/config
	config LUCI_APP_MMDVM
	bool "luci-app-mmdvm"
	depends on PACKAGE_${PKG_NAME}
	default y
	help
	  "LuCI plugin to configurate MMDVM Radio"
	
	config LUCI_THEME_BOOTSTRAP_MMDVM
	bool "luci-theme-bootstrap-mmdvm"
	depends on PACKAGE_${PKG_NAME}
	default y
	help
	  "LuCI bootstrap mod theme for MMDVM"

	config LUCI_SRCDIET
	bool "Minify Lua sources"
	depends on PACKAGE_${PKG_NAME}
	default y
	help
	  "Minify Lua sources"

	config LUCI_JSMIN
	bool "Minify JavaScript sources"
	depends on PACKAGE_${PKG_NAME}
	default y

   	config LUCI_CSSTIDY
	bool "Minify CSS files"
	depends on PACKAGE_${PKG_NAME}
	default y

	menu "Translations"$(foreach lang,$(LUCI_LANGUAGES),
    config LUCI_LANG_$(lang)
	  tristate "$(shell echo '$(LUCI_LANG.$(lang))' | sed -e 's/^.* (\(.*\))$$/\1/') ($(lang))")
  endmenu
endef

define Build/Compile

endef

define SrcDiet
	$(FIND) $(1) -type f -name '*.lua' | while read src; do \
		if LUA_PATH="$(STAGING_DIR_HOSTPKG)/lib/lua/5.1/?.lua" luasrcdiet --noopt-binequiv -o "$$$$src.o" "$$$$src"; \
		then mv "$$$$src.o" "$$$$src"; fi; \
	done
endef

define JsMin
	$(FIND) $(1) -type f -name '*.js' | while read src; do \
		if jsmin < "$$$$src" > "$$$$src.o"; \
		then mv "$$$$src.o" "$$$$src"; fi; \
	done
endef

define CssTidy
	$(FIND) $(1) -type f -name '*.css' | while read src; do \
		if csstidy "$$$$src" --template=highest --remove_last_semicolon=true "$$$$src.o"; \
		then mv "$$$$src.o" "$$$$src"; fi; \
	done
endef

define SubstituteVersion
	$(FIND) $(1) -type f -name '*.htm' | while read src; do \
		$(SED) 's/<%# *\([^ ]*\)PKG_VERSION *%>/\1$(if $(PKG_VERSION),$(PKG_VERSION),$(PKG_SRC_VERSION))/g' \
		    -e 's/"\(<%= *\(media\|resource\) *%>[^"]*\.\(js\|css\)\)"/"\1?v=$(if $(PKG_REVISION),$(PKG_REVISION),$(PKG_SRC_VERSION))"/g' \
			"$$$$src"; \
	done
endef

define Package/common/install
	if [ -d $(2)/luasrc ]; then \
	  $(INSTALL_DIR) $(1)$(LUCI_LIBRARYDIR); \
	  cp -pR ./$(2)/luasrc/* $(1)$(LUCI_LIBRARYDIR)/; \
		$(FIND) $(1)$(LUCI_LIBRARYDIR)/ -type f -name '*.luadoc' | $(XARGS) rm; \
	  $(if $(CONFIG_LUCI_SRCDIET),$(call SrcDiet,$(1)$(LUCI_LIBRARYDIR)/),true); \
		$(call SubstituteVersion,$(1)$(LUCI_LIBRARYDIR)/); \
	else true; fi
	if [ -d $(2)/htdocs ]; then \
	  $(INSTALL_DIR) $(1)$(HTDOCS); \
	  cp -pR ./$(2)/htdocs/* $(1)$(HTDOCS)/; \
	  $(if $(CONFIG_LUCI_JSMIN),$(call JsMin,$(1)$(HTDOCS)/),true); \
	  $(if $(CONFIG_LUCI_CSSTIDY),$(call CssTidy,$(1)$(HTDOCS)/),true); \
	else true; fi
	if [ -d $(2)/root ]; then \
	  $(INSTALL_DIR) $(1)/; \
	  cp -pR ./$(2)/root/* $(1)/; \
	  $(if $(CONFIG_LUCI_SRCDIET),$(call SrcDiet,$(1)/),true); \
	  mv $(1)/usr/sbin/dmrid.lua $(1)/usr/sbin/dmrid; \
	  chmod 750 $(1)/usr/sbin/dmrid; \
	else true; fi
	if [ -d $(2)/src ]; then \
	  $(call Build/Install/Default) \
	  $(CP) ./$(PKG_INSTALL_DIR)/* $(1)/; \
	else true; fi
endef


define Package/${PKG_NAME}/install
	$(call Package/common/install,$(1),luci-app-mmdvm)
	$(call Package/common/install,$(1),luci-theme-bootstrap-mmdvm)
endef

define Package/${PKG_NAME}/postinst
#!/bin/sh
if [ -e /etc/openwrt_release ]; then
	[ -f /etc/init.d/dmrid ] && /etc/init.d/dmrid enable || :
fi
exit 0
endef

LUCI_BUILD_PACKAGES := $(PKG_NAME)

define LuciTranslation
  define Package/$(PKG_NAME)-i18n-$(1)
    SECTION:=net
    CATEGORY:=MMDVM
    TITLE:=$(PKG_NAME) - $(1) translation
    HIDDEN:=1
    DEFAULT:=LUCI_LANG_$(1)||(ALL&&m)
    DEPENDS:=+$(PKG_NAME)
    PKGARCH:=all
  endef

  define Package/$(PKG_NAME)-i18n-$(1)/description
    Translation for $(PKG_NAME) - $(LUCI_LANG.$(1))
  endef

  define Package/$(PKG_NAME)-i18n-$(1)/install
	$$(INSTALL_DIR) $$(1)/etc/uci-defaults
	echo "uci set luci.languages.$(subst -,_,$(1))='$(LUCI_LANG.$(1))'; uci commit luci" \
		> $$(1)/etc/uci-defaults/$(PKG_NAME)-i18n-$(1)
	$$(INSTALL_DIR) $$(1)$(LUCI_LIBRARYDIR)/i18n
	$(foreach po,$(wildcard ./luci-app-mmdvm/po/$(1)/*.po), \
		po2lmo $(po) \
			$$(1)$(LUCI_LIBRARYDIR)/i18n/$(basename $(notdir $(po))).$(1).lmo;)
  endef

  define Package/$(PKG_NAME)-i18n-$(1)/postinst
	[ -n "$$$${IPKG_INSTROOT}" ] || {
		(. /etc/uci-defaults/$(PKG_NAME)-i18n-$(1)) && rm -f /etc/uci-defaults/$(PKG_NAME)-i18n-$(1)
		exit 0
	}
  endef

  LUCI_BUILD_PACKAGES += $(PKG_NAME)-i18n-$(1)

endef

$(foreach lang,$(LUCI_LANGUAGES),$(eval $(call LuciTranslation,$(lang))))
$(foreach pkg,$(LUCI_BUILD_PACKAGES),$(eval $(call BuildPackage,$(pkg))))
# $(eval $(call BuildPackage,${PKG_NAME}))