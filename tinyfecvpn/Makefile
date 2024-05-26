#
# Copyright (c) 2017 Yu Wang <wangyucn@gmail.com>
#
# This is free software, licensed under the MIT.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tinyfecVPN
PKG_VERSION:=20210116.0
PKG_RELEASE:=10

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/wangyu-/tinyfecVPN.git
PKG_SOURCE_DATE:=2021-01-17
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Yu Wang

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tinyfecvpn
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=A Network Improving Tool
  URL:=https://github.com/wangyu-/tinyfecVPN
  DEPENDS:=+libstdcpp +kmod-tun
endef

define Package/tinyfecvpn/description
  A Lightweight VPN with Build-in Forward Error Correction Support (or A Network Improving Tool
  which works at VPN mode). Improves your Network Quality on a High-latency Lossy Link.
endef

MAKE_FLAGS += nolimit_cross

define Build/Configure
	sed -i 's/cc_cross=.*/cc_cross=$(TARGET_CXX)/g' $(PKG_BUILD_DIR)/makefile
	sed -i '/\*gitversion/d' $(PKG_BUILD_DIR)/makefile
	echo 'const char *gitversion = "$(PKG_SOURCE_VERSION)";' > $(PKG_BUILD_DIR)/git_version.h

	$(call Build/Configure/Default)
endef

define Package/tinyfecvpn/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tinyvpn_cross $(1)/usr/bin/tinyvpn
endef

$(eval $(call BuildPackage,tinyfecvpn))
