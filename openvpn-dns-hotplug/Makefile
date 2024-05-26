include $(TOPDIR)/rules.mk

PKG_NAME:=openvpn-dns-hotplug
PKG_VERSION:=0.0.1
PKG_RELEASE:=4
PKG_MAINTAINER:=Konstantine Shevlakov <shevlakov@132lan.ru>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  PKGARCH:=all
  TITLE:=Openvpn DNS hotplug
  DEPENDS:=+openvpn
endef

define Package/$(PKG_NAME)/description
	Hotplug script to get NS attribytes: DNS and domain search.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef


define Package/$(PKG_NAME)/install
	$(CP) ./root/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

