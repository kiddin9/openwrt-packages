# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2020 Lean <coolsnowwolf@gmail.com>
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=alac
PKG_VERSION:=0.0.7
PKG_RELEASE:=4

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mikebrady/alac.git
PKG_SOURCE_DATE:=2019-02-13
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libalac
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=The Apple Lossless Audio Codec Library
  URL:=https://github.com/mikebrady/alac
  DEPENDS:=+libstdcpp
endef

define Package/libalac/description
  The Apple Lossless Audio Codec (ALAC) is an audio codec developed by
  Apple and supported on iPhone, iPad, most iPods, Mac and iTunes.
  ALAC is a data compression method which reduces the size of audio
  files with no loss of information. A decoded ALAC stream is
  bit-for-bit identical to the original uncompressed audio file.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libalac.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/alac.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/alac $(1)/usr/include/
endef

define Package/libalac/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libalac.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libalac))
