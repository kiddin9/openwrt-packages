#
# Copyright (C) 2022 jjm2473 <jjm2473@gmail.com>
#
# This is free software, licensed under the MIT License.
#

include $(TOPDIR)/rules.mk


PKG_NAME:=unishare
PKG_VERSION:=1.0.1
PKG_RELEASE:=8
PKG_MAINTAINER:=jjm2473 <jjm2473@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=File Transfer
	TITLE:=Unified Network Shares Manager
	DEPENDS:=+samba4-server +webdav2
	PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
	Configure samba, webdav (maybe more?) in one app
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/unishare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) ./files/unishare.init $(1)/etc/init.d/unishare
	$(INSTALL_CONF) ./files/unishare.config $(1)/etc/config/unishare
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
