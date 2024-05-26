# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=cxxopts
PKG_VERSION:=3.1.1
PKG_RELEASE:=11

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jarro2783/cxxopts/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS+= \
	-DCXXOPTS_ENABLE_INSTALL=ON \
	-DCXXOPTS_BUILD_EXAMPLES=OFF \
	-DCXXOPTS_BUILD_TESTS=OFF

define Package/cxxopts
  SECTION:=lib
  CATEGORY:=Libraries
  URL:=https://github.com/jarro2783/cxxopts
  TITLE:=Lightweight C++ command line option parser
  DEPENDS:=+libc
  BUILDONLY:=1
endef

define Package/cxxopts/description
  This is a lightweight C++ option parser library, supporting the
  standard GNU style syntax for options.
endef

$(eval $(call BuildPackage,cxxopts))
