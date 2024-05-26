#
# Copyright (C) 2022 Krypton Lee <jun.k.lee199410@outlook.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qt6base
PKG_BASE:=6.5
PKG_BUGFIX:=3
PKG_VERSION:=$(PKG_BASE).$(PKG_BUGFIX)
PKG_RELEASE:=9

PKG_SOURCE:=qtbase-everywhere-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://mirrors.tencent.com/qt/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules/ \
		  https://mirrors.aliyun.com/qt/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules/ \
		  http://download.qt-project.org/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules/
PKG_HASH:=skip

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/qtbase-everywhere-src-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/qtbase-everywhere-src-$(PKG_VERSION)

PKG_MAINTAINER:=Krypton Lee <jun.k.lee199410@outlook.com>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:qt:qt

PKG_BUILD_DEPENDS:=qt6base/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk

STRIP:=$(TARGET_CROSS)strip $(call qstrip,$(CONFIG_STRIP_ARGS))

define Package/libQt6/Default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Qt6
  TITLE:=Qt6
  URL:=http://qt-project.org
  DEPENDS:=@!(arc||TARGET_gemini) +libatomic +libdouble-conversion +libstdcpp +zlib
endef

define Package/libQt6
  $(call Package/libQt6/Default)
  HIDDEN:=1
endef

define Package/libQt6/install
endef

TARGET_CFLAGS+= -I$(STAGING_DIR)/usr/include/libdrm
ifdef CONFIG_USE_GLIBC
  ifeq ($(ARCH),x86_64)
    TARGET_LDFLAGS+= -Wl,--sysroot=$(TOOLCHAIN_DIR)
  endif
endif

CMAKE_SHARED_LDFLAGS := $(filter-out -Wl$(comma)-Bsymbolic-functions,$(CMAKE_SHARED_LDFLAGS))

CMAKE_HOST_OPTIONS+= \
	-DBUILD_SHARED_LIBS=OFF \
	-DFEATURE_optimize_full=ON \
	-DFEATURE_glib=OFF \
	-DFEATURE_zstd=OFF \
	-DFEATURE_concurrent=OFF \
	-DFEATURE_dbus=ON \
	-DFEATURE_gui=OFF \
	-DFEATURE_network=ON \
	-DFEATURE_openssl=OFF \
	-DFEATURE_sql=OFF \
	-DFEATURE_testlib=OFF \
	-DFEATURE_xml=ON

CMAKE_OPTIONS+= \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_SYSROOT=$(STAGING_DIR) \
	-DQT_HOST_PATH=$(STAGING_DIR_HOSTPKG) \
	-DINSTALL_PLUGINSDIR=/usr/lib/qt6plugins \
	-DQT_QMAKE_TARGET_MKSPEC=devices/linux-generic-g++ \
	-DQT_QMAKE_DEVICE_OPTIONS=CROSS_COMPILE="$(TARGET_CROSS);COMPILER_FLAGS=$(TARGET_CFLAGS) $(EXTRA_CFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS);LINKER_FLAGS=$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)" \
	-DQT_BUILD_EXAMPLES=OFF \
	-DQT_BUILD_TESTS=OFF \
	-DQT_BUILD_TOOLS_WHEN_CROSSCOMPILING=OFF \
	-DINPUT_opengl=no \
	-DFEATURE_optimize_full=ON \
	-DFEATURE_system_zlib=ON \
	-DFEATURE_zstd=OFF \
	-DFEATURE_backtrace=OFF \
	-DFEATURE_system_doubleconversion=ON \
	-DFEATURE_glib=OFF \
	-DFEATURE_icu=OFF \
	-DFEATURE_mimetype_database=ON \
	-DFEATURE_system_pcre2=ON \
	-DFEATURE_concurrent=$(if $(CONFIG_PACKAGE_libQt6Concurrent),ON,OFF) \
	-DFEATURE_dbus=$(if $(CONFIG_PACKAGE_libQt6DBus),ON,OFF) \
	-DFEATURE_gui=$(if $(CONFIG_PACKAGE_libQt6Gui),ON,OFF) \
	-DFEATURE_fontconfig=OFF \
	-DFEATURE_system_freetype=ON \
	-DFEATURE_accessibility=OFF \
	-DFEATURE_harfbuzz=OFF \
	-DFEATURE_gif=OFF \
	-DFEATURE_ico=OFF \
	-DFEATURE_jpeg=OFF \
	-DFEATURE_png=OFF \
	-DFEATURE_texthtmlparser=OFF \
	-DFEATURE_cssparser=OFF \
	-DFEATURE_textodfwriter=OFF \
	-DFEATURE_textmarkdownreader=OFF \
	-DFEATURE_textmarkdownwriter=OFF \
	-DFEATURE_sessionmanager=OFF \
	-DFEATURE_evdev=OFF \
	-DFEATURE_vnc=OFF \
	-DFEATURE_linuxfb=OFF \
	-DFEATURE_network=$(if $(CONFIG_PACKAGE_libQt6Network),ON,OFF) \
	-DFEATURE_openssl=ON \
	-DFEATURE_openssl_runtime=ON \
	-DFEATURE_ocsp=OFF \
	-DFEATURE_printsupport=$(if $(CONFIG_PACKAGE_libQt6PrintSupport),ON,OFF) \
	-DFEATURE_sql=$(if $(CONFIG_PACKAGE_libQt6Sql),ON,OFF) \
	-DFEATURE_sqlmodel=OFF \
	-DFEATURE_sql_sqlite=ON \
	-DFEATURE_system_sqlite=ON \
	-DFEATURE_sql_db2=OFF \
	-DFEATURE_sql_ibase=OFF \
	-DFEATURE_sql_mysql=OFF \
	-DFEATURE_sql_oci=OFF \
	-DFEATURE_sql_odbc=OFF \
	-DFEATURE_sql_psql=OFF \
	-DFEATURE_testlib=$(if $(CONFIG_PACKAGE_libQt6Test),ON,OFF) \
	-DFEATURE_itemmodeltester=OFF \
	-DFEATURE_widgets=$(if $(CONFIG_PACKAGE_libQt6Widgets),ON,OFF) \
	-DFEATURE_xml=$(if $(CONFIG_PACKAGE_libQt6Xml),ON,OFF) \
	-DFEATURE_tuiotouch=$(if $(CONFIG_PACKAGE_qt6-plugin-libqtuiotouchplugin),ON,OFF)

define Package/libQt6/Default/install
  	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libQt6$(2).so* $(1)/usr/lib/
endef

# 1: short name
# 2: dependencies on other qt6 libraries (short name)
# 3: dependencies on other packages
define DefineQt6Package
  QT6BASE_LIBS+=$(1)
  PKG_CONFIG_DEPENDS+=CONFIG_PACKAGE_libQt6$(1)

  define Package/libQt6$(1)
    $(call Package/libQt6/Default)
    TITLE+=$(1) Library
    DEPENDS+=$(foreach lib,$(2),+libQt6$(lib)) $(3)
  endef

  define Package/libQt6$(1)/description
    This package provides the Qt6 $(1) v$(PKG_VERSION) library.
  endef

  define Package/libQt6$(1)/install
	$(call Package/libQt6/Default/install,$$(1),$(1))
  endef
endef

$(eval $(call DefineQt6Package,Concurrent,Core,))
$(eval $(call DefineQt6Package,Core,,+libpcre2-16))
$(eval $(call DefineQt6Package,DBus,Core,))
$(eval $(call DefineQt6Package,Gui,DBus,+libdrm +libfreetype))
$(eval $(call DefineQt6Package,Network,Core,+libopenssl +krb5-libs))
$(eval $(call DefineQt6Package,PrintSupport,Widgets,))
$(eval $(call DefineQt6Package,Sql,Core,+libsqlite3))
$(eval $(call DefineQt6Package,Test,Core,))
$(eval $(call DefineQt6Package,Widgets,Gui,))
$(eval $(call DefineQt6Package,Xml,Core,))

define Package/qt6-plugin/Default/install
	$(INSTALL_DIR) $(1)/usr/lib/qt6plugins/$(2)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/qt6plugins/$(2)/libq$(3).so $(1)/usr/lib/qt6plugins/$(2)/
endef

# 1: plugin diretory
# 2: plugin name (short name)
# 3: dependencies on other qt6 libraries (short name)
define DefineQt6PluginPackage
  QT6_PLUGINS+=$(2)

  define Package/qt6-plugin-libq$(2)
    $(call Package/libQt6/Default)
    TITLE+=Plugin libq$(2)
    DEPENDS+=$(foreach lib,$(3),+libQt6$(lib))
  endef
  
  define Package/qt6-plugin-libq$(2)/install
	$(call Package/qt6-plugin/Default/install,$$(1),$(1),$(2))
  endef
endef

$(eval $(call DefineQt6PluginPackage,generic,tuiotouchplugin,Gui Network))
$(eval $(call DefineQt6PluginPackage,networkinformation,networkmanager,DBus Network))
$(eval $(call DefineQt6PluginPackage,platforms,minimal,Gui))
$(eval $(call DefineQt6PluginPackage,platforms,offscreen,Gui))
$(eval $(call DefineQt6PluginPackage,platformthemes,xdgdesktopportal,Gui))
$(eval $(call DefineQt6PluginPackage,sqldrivers,sqlite,Sql))
$(eval $(call DefineQt6PluginPackage,tls,certonlybackend,Network))
$(eval $(call DefineQt6PluginPackage,tls,opensslbackend,Network))
PKG_CONFIG_DEPENDS+=CONFIG_PACKAGE_qt6-plugin-libqtuiotouchplugin

$(foreach lib,$(QT6BASE_LIBS),$(eval $(call BuildPackage,libQt6$(lib))))
$(foreach lib,$(QT6_PLUGINS),$(eval $(call BuildPackage,qt6-plugin-libq$(lib))))
$(eval $(call BuildPackage,libQt6))
$(eval $(call HostBuild))
