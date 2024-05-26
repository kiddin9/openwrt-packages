include $(TOPDIR)/rules.mk

PKG_NAME:=fm350-modem
PKG_VERSION:=0.0.2
PKG_RELEASE:=8
PKG_MAINTAINER:=

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  PKGARCH:=all
  DEPENDS:=+comgt +kmod-usb-acm +kmod-usb-serial-option +kmod-usb-net-rndis
  TITLE:=Fibocom FM350 protocol
endef

define Package/$(PKG_NAME)/description
	Simple connect to cellular for Fibocom FM350 module
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
