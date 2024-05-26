# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=toml11
PKG_VERSION:=3.7.1
PKG_RELEASE:=8

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ToruNiina/toml11/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/toml11
  SECTION:=lib
  CATEGORY:=Libraries
  TITLE:=C++11 header-only toml parser/encoder
  URL:=https://github.com/ToruNiina/toml11
  BUILDONLY:=1
endef

define Package/toml11/description
  toml11 is a C++11 (or later) header-only toml parser/encoder
  depending only on C++ standard library.
endef

$(eval $(call BuildPackage,toml11))
