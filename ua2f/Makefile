# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2021 Xinyu Zhou <zhouxinyu1001@gmail.com>
# Copyright (C) 2021 Tianling Shen <cnsztl@immortalwrt.org>

include $(TOPDIR)/rules.mk

PKG_NAME:=UA2F
PKG_VERSION:=4.5.0
PKG_RELEASE:=9

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Zxilly/UA2F/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_UA2F_CUSTOM_USER_AGENT \
	CONFIG_UA2F_USER_AGENT_STRING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ua2f
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Change User-Agent to Fwords
  URL:=https://github.com/Zxilly/UA2F
  DEPENDS:=+libuci +libnetfilter-conntrack +libnetfilter-queue +kmod-nft-queue \
    +USE_GLIBC:libasan
endef

define Package/ua2f/description
  Change User-agent to Fwords to prevent being checked by Dr.Com.
endef

define Package/ua2f/config
  if PACKAGE_ua2f
	config UA2F_CUSTOM_USER_AGENT
	bool "Enable custom User-Agent"
	help
	  Enable this option to use a custom User-Agent string.

	config UA2F_USER_AGENT_STRING
	string "Custom User-Agent string"
	depends on UA2F_CUSTOM_USER_AGENT
	default "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.68"
	help
	  Specify the custom User-Agent string to use when UA2F_CUSTOM_USER_AGENT is enabled.
   endif
endef

CMAKE_OPTIONS += \
	-DUA2F_VERSION_STR="$(PKG_VERSION)" \
	-DUA2F_CUSTOM_USER_AGENT=$(if $(CONFIG_UA2F_CUSTOM_USER_AGENT),ON,OFF) \
	-DUA2F_USER_AGENT_STRING=$(CONFIG_UA2F_USER_AGENT_STRING)

define Package/ua2f/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ua2f $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/ua2f.config $(1)/etc/config/ua2f
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/ua2f.init $(1)/etc/init.d/ua2f
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/openwrt/files/ua2f.uci $(1)/etc/uci-defaults/80-ua2f
endef

$(eval $(call BuildPackage,ua2f))
