#
# Copyright (C) 2018 Jianhui Zhao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dcc2-wiwiz
PKG_VERSION:=8.0.0
PKG_RELEASE:=7

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/dcc2-wiwiz/Default
  SUBMENU:=Utilities
  SECTION:=net
  CATEGORY:=Wiwiz/PinPinWiFi
  TITLE:=Access your device from anywhere via the web
#  SECTION:=utils
#  CATEGORY:=Utilities
#  SUBMENU:=Terminal
  DEPENDS:=+libev $(2)
  VARIANT:=$(1)
  PROVIDES:=dcc2-wiwiz
endef

Package/dcc2-wiwiz-openssl=$(call Package/dcc2-wiwiz/Default,openssl,+PACKAGE_dcc2-wiwiz-openssl:libopenssl)
Package/dcc2-wiwiz-wolfssl=$(call Package/dcc2-wiwiz/Default,wolfssl,+PACKAGE_dcc2-wiwiz-wolfssl:libwolfssl)
Package/dcc2-wiwiz-mbedtls=$(call Package/dcc2-wiwiz/Default,mbedtls,+PACKAGE_dcc2-wiwiz-mbedtls:libmbedtls +PACKAGE_dcc2-wiwiz-mbedtls:zlib)
Package/dcc2-wiwiz-nossl=$(call Package/dcc2-wiwiz/Default,nossl)

define Package/dcc2-wiwiz-openssl/conffiles
/etc/config/dcc2-wiwiz
endef

Package/dcc2-wiwiz-wolfssl/conffiles = $(Package/dcc2-wiwiz-openssl/conffiles)
Package/dcc2-wiwiz-mbedtls/conffiles = $(Package/dcc2-wiwiz-openssl/conffiles)
Package/dcc2-wiwiz-nossl/conffiles = $(Package/dcc2-wiwiz-openssl/conffiles)

ifeq ($(BUILD_VARIANT),openssl)
  CMAKE_OPTIONS += -DUSE_OPENSSL=ON
else ifeq ($(BUILD_VARIANT),wolfssl)
  CMAKE_OPTIONS += -DUSE_WOLFSSL=ON
else ifeq ($(BUILD_VARIANT),mbedtls)
  CMAKE_OPTIONS += -DUSE_MBEDTLS=ON
else
  CMAKE_OPTIONS += -DSSL_SUPPORT=OFF
endif

define Package/dcc2-wiwiz-$(BUILD_VARIANT)/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/rtty $(1)/usr/sbin
	$(INSTALL_BIN) ./files/rtty.init $(1)/etc/init.d/rtty
	$(INSTALL_CONF) ./files/rtty.config $(1)/etc/config/rtty

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/rtty.lua $(1)/usr/lib/lua/luci/controller/rtty.lua
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/rtty.lua $(1)/usr/lib/lua/luci/model/cbi/rtty.lua

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci-defaults-rtty $(1)/etc/uci-defaults/rtty
endef

define Package/dcc2-wiwiz-$(BUILD_VARIANT)/postinst
#!/bin/sh
which uci > /dev/null || exit 0
uci -q get ucitrack.@rtty[0] > /dev/null || {
  uci add ucitrack rtty > /dev/null
  uci set ucitrack.@rtty[0].init=rtty
  uci commit
}
endef

define Package/dcc2-wiwiz-$(BUILD_VARIANT)/postrm
#!/bin/sh
which uci > /dev/null || exit 0
uci -q get ucitrack.@rtty[0] > /dev/null && {
  uci delete ucitrack.@rtty[0]
  uci commit
}
endef

$(eval $(call BuildPackage,dcc2-wiwiz-openssl))
$(eval $(call BuildPackage,dcc2-wiwiz-wolfssl))
$(eval $(call BuildPackage,dcc2-wiwiz-mbedtls))
$(eval $(call BuildPackage,dcc2-wiwiz-nossl))
