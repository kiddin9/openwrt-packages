#
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nxdn-clients
PKG_REV:=0c163b3
PKG_VERSION:=1.3.0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/lazywalker/NXDNClients.git
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=null
PKG_SOURCE_PROTO:=git
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Michael BD7MQB <bd7mqb@qq.com>


include $(INCLUDE_DIR)/package.mk

define Package/${PKG_NAME}
	SECTION:=net
	CATEGORY:=MMDVM
	TITLE:=MMDVM NXDNClients
	URL:=$(PKG_SOURCE_URL)
	DEPENDS:=+libpthread +libstdcpp
	USERID:=mmdvm:mmdvm
endef

define Package/${PKG_NAME}/description
Simple clients for NXDN. A gateway, parrot
endef

TARGET_CFLAGS += -std=c++0x -DOPENWRT=1

TARGET_LDFLAGS += \
        -Wl,-rpath-link=$(STAGING_DIR)/usr/lib \

MAKE_FLAGS +=\
        CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS)" \

define Package/${PKG_NAME}/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/NXDNGateway/NXDNGateway $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/NXDNParrot/NXDNParrot $(1)/usr/sbin/
	$(CP) -a files/* $(1)/
endef

define Package/${PKG_NAME}/conffiles
/etc/NXDNGateway.ini
endef

# define Package/${PKG_NAME}/postinst
# #!/bin/sh
# [ ! -f /etc/config/mmdvm ] && touch /etc/config/mmdvm
# [ -z `uci -q get mmdvm.NXDN.Enable` ] && {
# 	uci set mmdvm.NXDN=mmdvmhost
# 	uci set mmdvm.NXDN.Enable=0
# 	uci commit mmdvm
# }
# exit 0
# endef

$(eval $(call BuildPackage,${PKG_NAME}))
