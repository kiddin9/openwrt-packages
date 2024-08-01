#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=my-default-settings
PKG_VERSION:=1
PKG_RELEASE:=259

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=Default Settings
  MAINTAINER:=Kiddin'
  PKGARCH:=all
  DEPENDS:=+luci-base
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/
/etc/nginx/
endef

define Build/Prepare
	chmod -R +x ./files/bin ./files/sbin ./files/etc/profile.d ./files/etc/rc.d ./files/usr/share target/*/{*,}/base-files/{etc/init.d,usr/bin} >/dev/null || true
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
	echo $(BOARD)$(TARGETID)
	if [ -d ./target/$(BOARD)/base-files/. ]; then \
		$(CP) ./target/$(BOARD)/base-files/* $(1)/; \
	fi
	if [ -d ./target/$(TARGETID)/base-files/. ]; then \
		$(CP) ./target/$(TARGETID)/base-files/* $(1)/; \
	fi; \
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh_Hans/default.po $(1)/usr/lib/lua/luci/i18n/default.zh-cn.lmo

endef

$(eval $(call BuildPackage,$(PKG_NAME)))
