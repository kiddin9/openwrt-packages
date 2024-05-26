# Copyright (C) 2020-2024 Hyy2001X <https://github.com/Hyy2001X>

include $(TOPDIR)/rules.mk

PKG_NAME:=autoupdate
PKG_VERSION:=1
PKG_RELEASE:=7

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Upgrade OpenWrt by one-key
	DEPENDS:=+bash +jq
endef

define Package/$(PKG_NAME)/description
	autoupdate - One-key AutoUpdate
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) ./files/bin/autoupdate $(1)/bin
	$(INSTALL_DIR) $(1)/etc/autoupdate
	$(CP) ./files/etc/autoupdate/* $(1)/etc/autoupdate
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
