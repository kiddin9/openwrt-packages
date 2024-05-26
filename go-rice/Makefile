# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=go.rice
PKG_VERSION:=1.0.2
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/GeertJohan/go.rice/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

HOST_BUILD_DEPENDS:=golang/host
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/GeertJohan/go.rice
GO_PKG_BUILD_PKG:=$(GO_PKG)/rice

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-host-build.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/go-rice
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=A Go package that makes working with resources
  URL:=https://github.com/GeertJohan/go.rice
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/go-rice/description
  go.rice is a Go package that makes working with resources such as
  html,js,css,images and templates easy.

  During development go.rice will load required files directly from disk.
  Upon deployment it's easy to add all resource files to a executable
  using the rice tool without changing the source code for your package.

  go.rice provides methods to add resources to a binary in different scenarios.
endef

$(eval $(call GoBinHostBuild))
$(eval $(call HostBuild))
$(eval $(call GoBinPackage,go-rice))
$(eval $(call BuildPackage,go-rice))
