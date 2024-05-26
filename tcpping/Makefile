# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=tcpping
PKG_VERSION:=0.2
PKG_RELEASE=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/coolsnowwolf/tcping
PKG_SOURCE_DATE:=2020-09-19
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tcpping
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libnet-1.2.x +libpcap
  TITLE:=TCP Ping Tool
endef

define Package/tcpping/description
  Ping look-alike that uses TCP SYN packets to
  get around firewalls and ICMP blackholes.
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/lib/libnet-1.2.x/include -L$(STAGING_DIR)/usr/lib/libnet-1.2.x/lib" \
		INSTALL_PROG=":"
endef

define Package/tcpping/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tcpping $(1)/usr/bin/tcpping
endef

$(eval $(call BuildPackage,tcpping))
