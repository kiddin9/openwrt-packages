#
# Copyright (C) 2023-2024 muink
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
#go env

PKG_NAME:=alwaysonline
PKG_VERSION=1.2.0
PKG_RELEASE:=4

PKG_MAINTAINER:=muink <hukk1996@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Jamesits/alwaysonline.git
PKG_SOURCE_VERSION:=a12e3bdcbef1711c9ed5451d012015b54328045b
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/jamesits/alwaysonline/v2

AWOL_COMMIT_HASH:=$(shell echo $(PKG_SOURCE_VERSION)|cut -c -8)
AWOL_BUILD_TIME:=$(shell date -d @$(SOURCE_DATE_EPOCH) -u +%FT%TZ%z)
GO_PKG_LDFLAGS_X:=\
	main.versionGitCommitHash=$(AWOL_COMMIT_HASH) \
	main.versionCompileTime=$(AWOL_BUILD_TIME) \
	main.versionCompileHost=OpenWrt \
	main.versionGitStatus=clean

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Hijack/bypass Windows NCSI and iOS portal detection on a network level.
  URL:=https://github.com/Jamesits/alwaysonline
  DEPENDS:=$(GO_ARCH_DEPENDS)
  USERID:=alwaysonline:alwaysonline
endef

define Package/$(PKG_NAME)/description
  AlwaysOnline is a HTTP and DNS server which mocks a lot network/internet/portal detection servers.
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/sbin/
endef

define Package/uci-$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=alwaysonline uci metapackage
  DEPENDS:=+alwaysonline +kmod-tun +ip-full +rgmac
  USERID:=alwaysonline:alwaysonline
endef

define Package/uci-$(PKG_NAME)/conffiles/Default
/etc/config/alwaysonline
endef

Package/uci-$(PKG_NAME)/conffiles = $(Package/uci-$(PKG_NAME)/conffiles/Default)

define Package/uci-$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/alwaysonline.config $(1)/etc/config/alwaysonline

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/alwaysonline.init $(1)/etc/init.d/alwaysonline

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(CURDIR)/files/alwaysonline.defaults $(1)/etc/uci-defaults/99_alwaysonline
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,uci-$(PKG_NAME)))
