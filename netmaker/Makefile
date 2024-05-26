#
# Copyright (C) 2019 sbilly <superli_1980@hotmail.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netmaker
PKG_VERSION:=0.9.4
PKG_RELEASE:=46

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/gravitl/netmaker.git
PKG_SOURCE_VERSION:=e9bce264719f88c30e252ecc754d08f422f4c080
PKG_SOURCE_DATE:=20220117
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=sbilly <superli_1980@hotmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/gravitl/netmaker
GO_PKG_INSTALL_EXTRA:=extra/file extra/dir
GO_PKG_EXCLUDES:=excluded
GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/netmaker
$(call Package/netmaker/Default)
$(call GoPackage/GoSubMenu)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
endef

define Package/netmaker/Default
  TITLE:=Netmaker for OpenWRT
  URL:=https://github.com/gravitl/netmaker
  DEPENDS:=$(GO_ARCH_DEPENDS)
  MAINTAINER:=sbilly <superli_1980@hotmail.com>
endef

define Package/netmaker/Default/description
Netmaker is a platform for creating and managing fast, secure, and 
dynamic virtual overlay networks using WireGuard. This project offers
OpenWRT packages for Netmaker.
endef

define Package/netmaker/description
$(call Package/netmaker/Default/description)

This package contains the binaries.
endef

define Package/netmaker-dev
  TITLE+= (source files)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  PKGARCH:=all
endef

define Package/netmaker-dev/description
$(call Package/netmaker/Default/description)

This package provides the source files.
endef

define Package/netmaker/install
	$(INSTALL_DIR) $(1)/etc/netclient/
	$(INSTALL_DIR) $(1)/etc/netclient/config
	$(INSTALL_DIR) $(1)/etc/systemd/
	$(INSTALL_DIR) $(1)/etc/systemd/system
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/netmaker $(1)/usr/bin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/netclient $(1)/usr/bin/
	$(CP) ./root/* $(1)/
	$(LN) netclient $(1)/etc/netclient/netclient
endef

$(eval $(call GoBinPackage,netmaker))
$(eval $(call BuildPackage,netmaker))

$(eval $(call GoSrcPackage,netmaker-dev))
$(eval $(call BuildPackage,netmaker-dev))
