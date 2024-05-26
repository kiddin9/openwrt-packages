include $(TOPDIR)/rules.mk

PKG_NAME:=mhz
PKG_RELEASE:=5

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/wtarreau/mhz.git
PKG_SOURCE_DATE:=2023-06-17
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Robert Marko <robimarko@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/mhz
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CPU frequency measurement utility
  URL:=https://github.com/wtarreau/mhz
endef

define Package/mhz/description
  Tool to mathematically calculate the current CPU frequency.
endef

define Package/mhz/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mhz $(1)/usr/sbin/mhz
endef

$(eval $(call BuildPackage,mhz))
