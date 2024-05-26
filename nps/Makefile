# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=nps
PKG_VERSION:=0.26.18
PKG_RELEASE:=31

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/yisier/nps/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINTER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=ehang.io/nps
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/...

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define nps/templates
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=A intranet penetration proxy server ($(1))
    DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
    URL:=https://ehang-io.github.io/nps
  endef

  define Package/$(1)/description
  NPS is a lightweight, high-performance, powerful intranet penetration proxy server,
  with a powerful web management terminal.

  This package contains the $(1).
  endef

  define Package/$(1)/install
	$$(call GoPackage/Package/Install/Bin,$$(PKG_INSTALL_DIR))

	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/
  endef
endef

NPS_COMPONENTS:=npc nps

$(foreach component,$(NPS_COMPONENTS), \
  $(eval $(call nps/templates,$(component))) \
  $(eval $(call GoBinPackage,$(component))) \
  $(eval $(call BuildPackage,$(component))) \
)
