# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=libcryptopp
PKG_VERSION:=8.9.0
PKG_RELEASE:=21

PKG_SOURCE:=cryptopp$(subst .,,$(PKG_VERSION)).zip
PKG_SOURCE_URL:=https://github.com/weidai11/cryptopp/releases/download/CRYPTOPP_$(subst .,_,$(PKG_VERSION))/ \
		https://www.cryptopp.com/
PKG_HASH:=skip

PKG_LICENSE:=BSL-1.0
PKG_LICENSE_FILES:=License.txt
PKG_CPE_ID:=cpe:/a:cryptopp:crypto++

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

UNZIP_CMD:=unzip -q -d $(PKG_BUILD_DIR) $(DL_DIR)/$(PKG_SOURCE)

define Package/libcryptopp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Free C++ class library of cryptographic schemes
  URL:=https://packages.debian.org/sid/libcrypto++-dev
  DEPENDS:=+libpthread +libstdcpp
endef

define Package/libcryptopp/description
  Crypto++ is library for creating C++ programs which use cryptographic
  algorithms. The library uses a Pipes & Filters architecture with heavy
  use of templates and abstract base classes.
endef

ifdef CONFIG_TARGET_x86
  TARGET_CFLAGS+= $(FPIC)
endif

MAKE_FLAGS+= dynamic libcryptopp.pc

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/cryptopp
	$(CP) $(PKG_INSTALL_DIR)/usr/local/include/cryptopp/* $(1)/usr/include/cryptopp/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/pkgconfig/libcryptopp.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libcryptopp.so* $(1)/usr/lib/
endef

define Package/libcryptopp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libcryptopp.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libcryptopp))
