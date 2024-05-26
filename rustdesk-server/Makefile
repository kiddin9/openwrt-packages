# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=rustdesk-server
PKG_VERSION:=1.1.10-3
PKG_RELEASE:=7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rustdesk/rustdesk-server/tar.gz/$(PKG_VERSION)?
PKG_HASH:=skip

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/rustdesk-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=RustDesk Server Program
  DEPENDS:=@(aarch64||arm||i386||i686||x86_64)
  URL:=https://rustdesk.com/server
endef

define Package/rustdesk-server/description
  Self-host your own RustDesk server, it is free and open source.
endef

$(eval $(call RustBinPackage,rustdesk-server))
$(eval $(call BuildPackage,rustdesk-server))
