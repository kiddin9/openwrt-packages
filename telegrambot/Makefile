include $(TOPDIR)/rules.mk

PKG_NAME:=telegrambot
PKG_VERSION:=0.0.4
PKG_RELEASE:=5
PKG_MAINTAINER:=Konstantine Shevlakov <shevlakov@132lan.ru>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  PKGARCH:=all
  DEPENDS:=+curl
  TITLE:=Openwrt Telegram Bot
endef

define Package/$(PKG_NAME)/description
	Telegram bot for router with firmware Lede/Openwrt.
endef

define Package.$(PKG_NAME)/conffiles
	/etc/config/telegrambot
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
