# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=transfer
PKG_VERSION:=0.4.17
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Mikubill/transfer/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/Mikubill/transfer

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/transfer
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=File Transfer
  TITLE:=Large file transfer tool with multiple file transfer services support
  URL:=https://github.com/Mikubill/transfer
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

$(eval $(call GoBinPackage,transfer))
$(eval $(call BuildPackage,transfer))
