include $(TOPDIR)/rules.mk

PKG_NAME:=atinout
PKG_VERSION=0.9.1

PKG_MAINTAINER:=Konstantine Shevlakov <shevlakov@132lan.ru>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/beralt/atinout.git
PKG_SOURCE_VERSION:=null

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Telephony
	TITLE:=Send AT commands to a modem
	URL:=http://atinout.sourceforge.net/
	MAINTAINER:=Adrian Guenter <a@gntr.me>
endef

define Package/$(PKG_NAME)/description
	Atinout is a program that will execute AT commands in sequence and
	capture the response from the modem.
endef


CONFIGURE_VARS += \
  CC="$(TARGET_CC)" \
  CXX="$(TARGET_CC) +.c++" \
  CFLAGS="$(TARGET_CFLAGS) -Wall -DVERSION=\"\\\"$(PKG_VERSION)\\\"\"" \
  LDFLAGS="$(TARGET_LDFLAGS)"

define Build/Configure
	$(call Build/Configure/Default,--with-linux-headers=$(LINUX_DIR))
endef

define Build/Compile
	@echo -e "\n=== Build/Compile ==="
	$(CONFIGURE_VARS) $(MAKE) -C $(PKG_BUILD_DIR) \
		all \

endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin/$(PKG_NAME)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
