# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=go-wol
PKG_VERSION:=2.0.1
PKG_RELEASE:=6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sabhiram/go-wol/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/sabhiram/go-wol/cmd/wol

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/go-wol
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Simple wake on LAN magic packet generator for golang
  URL:=https://github.com/sabhiram/go-wol
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/go-wol/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wol $(1)/usr/bin/go-wol
endef

$(eval $(call GoBinPackage,go-wol))
$(eval $(call BuildPackage,go-wol))
