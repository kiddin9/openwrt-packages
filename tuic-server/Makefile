# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=tuic-server
PKG_VERSION:=1.0.0
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/EAimTY/tuic/tar.gz/tuic-server-$(PKG_VERSION)?
PKG_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_NAME)

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1)/.. $(TAR_OPTIONS)

define Package/tuic-server
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Delicately-TUICed 0-RTT proxy protocol (server)
  URL:=https://github.com/EAimTY/tuic
  DEPENDS:=@(aarch64||arm||x86_64)
endef

$(eval $(call RustBinPackage,tuic-server))
$(eval $(call BuildPackage,tuic-server))
