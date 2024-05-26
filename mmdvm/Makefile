#
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mmdvm
PKG_VERSION:=1.0.7
PKG_RELEASE:=5
GIT_REVISION:=$(shell git rev-parse --short HEAD)
PKG_REVISION:=$(PKG_VERSION)-$(PKG_RELEASE)-$(GIT_REVISION)
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Michael BD7MQB <bd7mqb@qq.com>

include $(INCLUDE_DIR)/package.mk

define Package/${PKG_NAME}
	SECTION:=net
	CATEGORY:=MMDVM
	TITLE:=MMDVM Suite
	URL:=
	DEPENDS:=+mmdvm-luci +mmdvm-host
endef

define Package/${PKG_NAME}/description
The MMDVM Suite for OpenWrt
endef

define Build/Compile

endef

define Package/${PKG_NAME}/install
	$(CP) -a files/* $(1)/
	mv $(1)/usr/sbin/mmdvmctl.sh $(1)/usr/sbin/mmdvmctl
	chmod 750 $(1)/usr/sbin/mmdvmctl
endef

$(eval $(call BuildPackage,${PKG_NAME}))