#
# (с) 2024 gSpot (https://github.com/gSpotx2f/luci-app-internet-detector)
#

include $(TOPDIR)/rules.mk

PKG_NAME:=internet-detector-mod-modem-restart
PKG_VERSION:=1.3
PKG_RELEASE:=0
PKG_MAINTAINER:=gSpot <https://github.com/gSpotx2f/luci-app-internet-detector>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Modem restart module for internet-detector
  URL:=https://github.com/gSpotx2f/luci-app-internet-detector
  PKGARCH:=all
  DEPENDS:=+internet-detector +modemmanager
endef

define Package/$(PKG_NAME)/description
  Support modem restart for internet detector.
endef

define Package/$(PKG_NAME)/conffiles
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/internet-detector
	$(INSTALL_DATA) ./files/usr/lib/lua/internet-detector/mod_modem_restart.lua $(1)/usr/lib/lua/internet-detector/mod_modem_restart.lua
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
