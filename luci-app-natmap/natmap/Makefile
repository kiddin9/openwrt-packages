include $(TOPDIR)/rules.mk

PKG_NAME:=natmap
PKG_VERSION:=20240303
PKG_RELEASE:=

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/heiher/natmap/releases/download/$(PKG_VERSION)
PKG_HASH:=d7b7a1ba2fc8dbd471ed88757fa6fc7c7e2d83f9f44c8f62661e9809d386d163

PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=License

PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/natmap
  SECTION:=net
  CATEGORY:=Network
  TITLE:=TCP/UDP port mapping tool for full cone NAT
  URL:=https://github.com/heiher/natmap
  DEPENDS:=+jq +curl +openssl-util
endef

MAKE_FLAGS += REV_ID="$(PKG_VERSION)"

define Package/${PKG_NAME}/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/natmap $(1)/usr/bin/
endef

$(eval $(call BuildPackage,natmap))
