#
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libwxwidgets
PKG_REV:=WX_3_0_BRANCH
PKG_VERSION:=3.0
PKG_RELEASE:=6

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/lazywalker/wxWidgets
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=git
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Michael BD7MQB <bd7mqb@qq.com>

PKG_INSTALL:=1
PKG_CHECK_FORMAT_SECURITY:=0

include $(INCLUDE_DIR)/package.mk

define Package/${PKG_NAME}
	SECTION:=lib
	CATEGORY:=MMDVM
	TITLE:=Cross-Platform GUI Library
	URL:=https://www.wxwidgets.org
	DEPENDS:=+libexpat +libstdcpp +zlib +libpthread
endef

define Package/${PKG_NAME}/description
Cross-Platform GUI Library
endef

TARGET_CFLAGS += $(FPIC) 
	-DOPENWRT=1 \
	-D wxUSE_STD_STRING_CONV_IN_WXSTRING=1 \
	-D wxUSE_STD_CONTAINERS=1 \
	-D wxUSE_IPV6=1 \
	-D wxUSE_ANY=1 \
	-D wxUSE_COMPILER_TLS=1 \
	-D wxUSE_CONSOLE_EVENTLOOP=1 \
	-D wxUSE_FILE_HISTORY=1 \
	-D wxUSE_FSWATCHER=1 \
	-D wxUSE_XLOCALE=1

CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-unicode \
	--disable-static \
	--disable-rpath \
	--with-gnu-ld \
	--disable-gui \
	--disable-monolithic \
	--enable-plugins \
	--disable-universal \
	--disable-nanox \
	--disable-gtk2 \
	--disable-gpe \
	--disable-optimise \
	--disable-debug \
	--disable-stl \
	--disable-omf \
	--disable-debug_flag \
	--disable-debug_info \
	--disable-debug_gdb \
	--disable-debug_cntxt \
	--disable-mem_tracing \
	--disable-profile \
	--disable-no_rtti \
	--disable-no_exceptions \
	--disable-compat22 \
	--disable-compat24 \
	--enable-intl \
	--disable-backtrace \
	--enable-exceptions \
	--disable-sound \
	--enable-largefile \
	--without-gtk \
	--without-motif \
	--without-mac \
	--without-cocoa \
	--without-wine \
	--without-msw \
	--without-pm \
	--without-mgl \
	--without-microwin \
	--without-x11 \
	--without-libpng \
	--without-libjpeg \
	--without-libtiff \
	--without-libxpm \
	--without-libmspack \
	--without-sdl \
	--without-gnomeprint \
	--without-opengl \
	--without-dmalloc \
	--with-regex="sys" \
	--with-zlib="sys" \
	--without-odbc \
	--with-expat="sys" \
	--without-gtk-prefix \
	--without-x \
	--without-libiconv-prefix \
	--without-sdl-prefix \
	--without-cppunit-prefix \
	--disable-precomp-headers 

# define Build/InstallDev
# 	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/include $(1)/usr/lib
# 	$(CP) -L $(PKG_BUILD_DIR)/wx-config $(1)/usr/bin/
# 	$(CP) $(PKG_INSTALL_DIR)/usr/include/wx-3.0 $(1)/usr/include/
# 	$(CP) -rf  $(PKG_INSTALL_DIR)/usr/include/wx-3.0/* $(1)/usr/include/
# 	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwx_baseu{,_net,_xml}-*.a* $(1)/usr/lib/
# 	$(CP) $(PKG_INSTALL_DIR)/usr/lib/wx $(1)/usr/lib/
# 	$(SED) 's,-I$$$${includedir}/wx-3.0,-I$(STAGING_DIR)/usr/include/wx-3.0,g' $(1)/usr/bin/wx-config
# 	$(SED) 's,-I$$$${libdir}/wx/include,-I$(STAGING_DIR)/usr/lib/wx/include,g' $(1)/usr/bin/wx-config
# endef

define Build/Clean
	rm -rf $(STAGING_DIR)/usr/include/wx
	rm -rf $(STAGING_DIR)/usr/lib/libwx*
endef

define Package/${PKG_NAME}/install
	# toolchains
	$(CP) -rf $(PKG_BUILD_DIR)/include/wx $(STAGING_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/lib/wx/include/*linux-base-unicode-$(PKG_VERSION)/wx/setup.h  $(STAGING_DIR)/usr/include/wx/
	$(CP) -rf $(PKG_INSTALL_DIR)/usr/lib/libwx*.so.* $(STAGING_DIR)/usr/lib/
	$(CP) -rf $(PKG_INSTALL_DIR)/usr/lib/libwx_baseu-$(PKG_VERSION)*.so $(STAGING_DIR)/usr/lib/libwx_baseu-$(PKG_VERSION).so
	$(CP) -rf $(PKG_INSTALL_DIR)/usr/lib/libwx_baseu_net-$(PKG_VERSION)*.so $(STAGING_DIR)/usr/lib/libwx_baseu_net-$(PKG_VERSION).so
	$(CP) -rf $(PKG_INSTALL_DIR)/usr/lib/libwx_baseu_xml-$(PKG_VERSION)*.so $(STAGING_DIR)/usr/lib/libwx_baseu_xml-$(PKG_VERSION).so

	# ipk
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) -rf $(PKG_INSTALL_DIR)/usr/lib/libwx*.so.* $(1)/usr/lib/
	$(CP) -rf $(PKG_INSTALL_DIR)/usr/lib/libwx_baseu-$(PKG_VERSION)*.so $(1)/usr/lib/libwx-baseu-$(PKG_VERSION).so
	$(CP) -rf $(PKG_INSTALL_DIR)/usr/lib/libwx_baseu_net-$(PKG_VERSION)*.so $(1)/usr/lib/libwx-baseu_net-$(PKG_VERSION).so
	$(CP) -rf $(PKG_INSTALL_DIR)/usr/lib/libwx_baseu_xml-$(PKG_VERSION)*.so $(1)/usr/lib/libwx_baseu_xml-$(PKG_VERSION).so
endef

$(eval $(call BuildPackage,${PKG_NAME}))