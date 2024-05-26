#
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ysf-clients
PKG_REV:=ec16283
PKG_VERSION:=1.3.0
PKG_RELEASE:=7

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/lazywalker/YSFClients.git
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=git
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Michael BD7MQB <bd7mqb@qq.com>

include $(INCLUDE_DIR)/package.mk

define Package/${PKG_NAME}
	SECTION:=net
	CATEGORY:=MMDVM
	TITLE:=MMDVM YSFClients
	URL:=$(PKG_SOURCE_URL)
	DEPENDS:=+libpthread +libstdcpp
endef

define Package/${PKG_NAME}/description
System Fusion network servers, including gateway and parrot.
endef

TARGET_CFLAGS += -std=c++0x -DOPENWRT=1

TARGET_LDFLAGS += \
        -Wl,-rpath-link=$(STAGING_DIR)/usr/lib \

MAKE_FLAGS +=\
        CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS)" \

define Package/${PKG_NAME}/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/YSFGateway/YSFGateway $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/YSFParrot/YSFParrot $(1)/usr/sbin/
	$(CP) -a files/* $(1)/
endef

define Package/${PKG_NAME}/conffiles
/etc/YSFGateway.ini
endef

# define Package/${PKG_NAME}/postinst
# #!/bin/sh
# [ ! -f /etc/config/mmdvm ] && touch /etc/config/mmdvm
# [ -z `uci -q get mmdvm.System_Fusion.Enable` ] && {
# 	uci set mmdvm.System_Fusion=mmdvmhost
# 	uci set mmdvm.System_Fusion.Enable=1
# 	uci commit mmdvm
# }
# exit 0
# endef

$(eval $(call BuildPackage,${PKG_NAME}))
