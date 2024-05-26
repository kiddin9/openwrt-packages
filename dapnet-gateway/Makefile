#
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dapnet-gateway
PKG_REV:=631297e
PKG_VERSION:=1.3.0
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/lazywalker/DAPNETGateway.git
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
	TITLE:=DAPNET Gateway for MMDVM
	URL:=https://github.com/g4klx/DAPNETGateway
	DEPENDS:=+libpthread +libstdcpp
endef

define Package/${PKG_NAME}/description
Gateway to the DAPNET POCSAG network
endef

TARGET_LDFLAGS = -L$(STAGING_DIR)/usr/lib

MAKE_FLAGS +=\
        LDFLAGS="$(TARGET_LDFLAGS)" \

define Package/${PKG_NAME}/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/DAPNETGateway $(1)/usr/sbin/
	$(CP) -a files/* $(1)/
endef

define Package/${PKG_NAME}/conffiles
/etc/DAPNETGateway.ini
endef

# define Package/${PKG_NAME}/postinst
# #!/bin/sh
# [ ! -f /etc/config/mmdvm ] && touch /etc/config/mmdvm
# [ -z `uci -q get mmdvm.POCSAG.Enable` ] && {
# 	uci set mmdvm.POCSAG=mmdvmhost
# 	uci set mmdvm.POCSAG.Enable=0
# 	uci commit mmdvm
# }
# exit 0
# endef

$(eval $(call BuildPackage,${PKG_NAME}))