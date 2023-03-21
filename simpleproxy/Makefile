include $(TOPDIR)/rules.mk

PKG_NAME:=simpleproxy
PKG_VERSION:=3.5
PKG_RELEASE:=3

PKG_MAINTAINER:=Konstantine Shevlakov <shevlakov@132lan.ru>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/vzaliva/simpleproxy.git
PKG_SOURCE_VERSION:=null

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=simpleproxy OpenWRT package
  URL:=https://github.com/vzaliva/simpleproxy
endef

define Package/$(PKG_NAME)/description
	Simpleproxy is a simple TCP proxy. It accepts connections on a local
	TCP port and forward them to anoter port on a remote host via TCP.
endef

define Package/$(PKG_NAME)/prepare
	./configure --prefix=/usr
endef

define Package/$(PKG_NAME)/prepare
	$(MAKE)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/simpleproxy $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sample.cfg $(1)/etc/simpleproxy.cfg
endef


$(eval $(call BuildPackage,$(PKG_NAME)))


