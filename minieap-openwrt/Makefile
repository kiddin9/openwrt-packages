include $(TOPDIR)/rules.mk

PKG_NAME:=minieap
PKG_VERSION:=0.93.7
PKG_RELEASE:=7
PKG_MAINTAINER:=lala <maoerpet@foxmail.com>
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/AutoCONFIG/minieap.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=null
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Extensible 802.1x client with Ruijie v3 (v4) plugin
	MAINTAINER:=updateing && lala
	URL:=https://github.com/ZenZRyan
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/minieap $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/minieap.sh $(1)/lib/netifd/proto/
	$(INSTALL_BIN) ./files/minieap.script $(1)/lib/netifd/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/minieap $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
