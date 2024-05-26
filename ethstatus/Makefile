include $(TOPDIR)/rules.mk

PKG_NAME:=ethstatus
PKG_VERSION:=0.4.9
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://deb.debian.org/debian/pool/main/e/ethstatus/
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=console-based ethernet statistics monitor
  URL:=https://packages.debian.org/unstable/ethstatus
  DEPENDS:=+libncurses
endef

define Package/$(PKG_NAME)/description
Ethstatus is a console-based monitoring utility for
displaying statistical data of the ethernet interface
on a quantity basis. It is similar to iptraf but is meant
to run as a permanent console task to monitor the network
load.
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
