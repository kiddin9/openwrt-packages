# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=jpcre2
PKG_VERSION:=10.32.01
PKG_RELEASE:=22

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jpcre2/jpcre2/tar.gz/$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=BSD 3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=pcre2
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/jpcre2
  SECTION:=lib
  CATEGORY:=Libraries
  TITLE:=C++ wrapper for PCRE2 Library
  URL:=https://github.com/jpcre2/jpcre2
  BUILDONLY:=1
endef

define Package/jpcre2/description
  This provides some C++ wrapper classes/functions to perform regex
  operations such as regex match and regex replace.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/jpcre2.hpp $(1)/usr/include/jpcre2.hpp
endef

$(eval $(call BuildPackage,jpcre2))
