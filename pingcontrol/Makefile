
include $(TOPDIR)/rules.mk

PKG_NAME:=pingcontrol
PKG_VERSION:=1
PKG_RELEASE:=6
PKG_BUILD_DIR:=$(BUILD_DIR)/pingcontrol

include $(INCLUDE_DIR)/package.mk

define Package/pingcontrol
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Network interface watchdog
  PKGARCH:=all
endef

define Package/pingcontrol/description
	 This package contains a utility for managing the interface using ping requests.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/pingcontrol/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) ./files/pingcontrol $(1)/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/pingcontrol.config $(1)/etc/config/pingcontrol
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pingcontrol.init $(1)/etc/init.d/pingcontrol
endef

$(eval $(call BuildPackage,pingcontrol))
