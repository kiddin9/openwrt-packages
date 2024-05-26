#
# Copyright (C) 2013-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=accel-ppp
PKG_RELEASE:=7
PKG_VERSION:=1.11.2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/xebd/accel-ppp.git
PKG_SOURCE_VERSION:=04aaeb9bb66c7150bcfea7aadf48663624676316

PKG_MAINTAINER:=Alex Paraskeva <sim201010@gmail.com>
PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

#PKG_INSTALL:=1
#PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_accel-ppp_$(BUILD_VARIANT)_ext_cer_id

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/accel-ppp
  SECTION:=net
  CATEGORY:=Network
  TITLE:=accel-ppp VPN server
  DEPENDS:=+libpcre +libopenssl +libpthread +librt +libatomic
endef

CMAKE_OPTIONS += \
	-DBUILD_DRIVER=FALSE \
	-DKDIR=$(LINUX_DIR) \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE=Release \
	-DLOG_PGSQL=FALSE \
	-DSHAPER=TRUE \
	-DRADIUS=TRUE \
	-DNETSNMP=FALSE \
	-DLOG_FILE=TRUE \
	-DLIB_SUFFIX= \

TARGET_CFLAGS += -I$(STAGING_DIR)/opt/include -D_GNU_SOURCE -g -O2 -Wno-incompatible-pointer-types
TARGET_LDFLAGS += -lpthread -latomic

define Package/accel-ppp/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/usr/bin \
		$(1)/usr/share/accel-ppp \
		$(1)/usr/share/accel-ppp/radius \
		$(1)/usr/share/accel-ppp/l2tp \
		$(1)/usr/lib/accel-ppp \
		$(1)/etc/init.d \
		$(1)/etc/accel-ppp

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/accel-pppd \
		$(1)/usr/sbin/

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/accel-cmd \
		$(1)/usr/bin/

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/lib/accel-ppp/*.so \
		$(1)/usr/lib/accel-ppp/

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/lib/accel-ppp/libtriton.so \
		$(1)/usr/lib/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/accel-ppp/radius/dictionary.* \
		$(1)/usr/share/accel-ppp/radius/

	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/accel-ppp/l2tp/dictionary.* \
		$(1)/usr/share/accel-ppp/l2tp/

	$(INSTALL_BIN) \
		files/accel-ppp.init \
		$(1)/etc/init.d/accel-ppp

	$(INSTALL_DATA) \
		files/accel-ppp.conf \
		$(1)/etc/accel-ppp

endef

$(eval $(call BuildPackage,accel-ppp))
