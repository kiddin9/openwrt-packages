include $(TOPDIR)/rules.mk

PKG_NAME:=rrm-nr-distributor
PKG_VERSION:=0.0.1
PKG_RELEASE:=3
PKG_MAINTAINER:=Konstantine Shevlakov <shevlakov@132lan.ru>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  PKGARCH:=all
  DEPENDS:=+umdns
  TITLE:=802.11k Neighbor Report distributor daemon
endef

define Package/$(PKG_NAME)/description
	802.11k Neighbor Report distributor daemon
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
