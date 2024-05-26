#
# Copyright (C) 2007-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wxbase
PKG_VERSION:=3.2.4
PKG_RELEASE:=22

PKG_SOURCE:=wxWidgets-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/wxWidgets/wxWidgets/releases/download/v$(PKG_VERSION)
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/wxWidgets-$(PKG_VERSION)
PKG_CHECK_FORMAT_SECURITY:=0
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

DISABLE_NLS:=

define Package/libwxbase
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Cross-platform C++ framework
  URL:=http://www.wxwidgets.org/
  DEPENDS:=+libexpat +libstdcpp +zlib +libpcre2-32 +libcurl
endef

define Package/libwxbase/description
  wxBase contains most of the non-GUI classes from the wxWindows cross-
  -platform C++ framework. There are 2 categories: generally useful portable
  code (date/time handling, command line parsing, regular expression support)
  and wrappers for the OS objects (files, directories, sockets, threads,
  etc.) allowing you to write portable programs easily.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--disable-backtrace \
	--disable-compat28 \
	--disable-compat30 \
	--disable-debug \
	--disable-debug_flag \
	--disable-debug_info \
	--disable-debug_gdb \
	--disable-debug_cntxt \
	--disable-gpe \
	--disable-gui \
	--disable-mediactrl \
	--disable-mem_tracing \
	--disable-monolithic \
	--disable-nanox \
	--disable-no_rtti \
	--disable-no_exceptions \
	--disable-precomp-headers \
	--disable-profile \
	--disable-rpath \
	--disable-sound \
	--disable-stl \
	--disable-universal \
	--enable-exceptions \
	--enable-intl \
	--enable-largefile \
	--enable-optimise \
	--enable-plugins \
	--enable-shared \
	--enable-unicode \
	\
	--with-expat="sys" \
	--with-regex="sys" \
	--with-zlib="sys" \
	--without-cocoa \
	--without-dmalloc \
	--without-gtk-prefix \
	--without-gtk \
	--without-libiconv-prefix \
	--without-libjbig \
	--without-libjpeg \
	--without-libmspack \
	--without-libpng \
	--without-libtiff \
	--without-libxpm \
	--without-mac \
	--without-motif \
	--without-msw \
	--without-opengl \
	--without-sdl \
	--without-sdl-prefix \
	--without-wine \
	--without-x \
	--without-x11

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wx-config $(1)/usr/bin/
	$(SED) "s,$(PKG_BUILD_DIR),$(STAGING_DIR)/usr,g" $(1)/usr/bin/wx-config
	$(SED) 's,-I$$$${includedir}/wx-3.2,-I$(STAGING_DIR)/usr/include/wx-3.2,g' $(1)/usr/bin/wx-config
	$(SED) 's,-I$$$${libdir}/wx/include,-I$(STAGING_DIR)/usr/lib/wx/include,g' $(1)/usr/bin/wx-config

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/wx-3.2 $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwx_*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/wx $(1)/usr/lib/
endef

define Package/libwxbase/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwx_*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwxbase))
