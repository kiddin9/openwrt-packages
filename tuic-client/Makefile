# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=tuic-client
PKG_VERSION:=1.0.0
PKG_RELEASE:=28

PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

include $(INCLUDE_DIR)/package.mk

TUIC_TYPE:=tuic-client-$(PKG_VERSION)
TUIC_FOOT:=unknown-linux-musl
ifeq ($(ARCH),aarch64)
	TUIC_ARCH:=$(TUIC_TYPE)-aarch64-$(TUIC_FOOT)
	PKG_HASH:=skip
else ifeq ($(ARCH),arm)
# Referred to golang/golang-values.mk
	ARM_CPU_FEATURES:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))
	ifeq ($(ARM_CPU_FEATURES),)
		TUIC_ARCH:=$(TUIC_TYPE)-armv7-$(TUIC_FOOT)eabi
		PKG_HASH:=skip
	else
		TUIC_ARCH:=$(TUIC_TYPE)-armv7-$(TUIC_FOOT)eabihf
		PKG_HASH:=skip
	endif
else ifeq ($(ARCH),i386)
	TUIC_ARCH:=$(TUIC_TYPE)-i686-$(TUIC_FOOT)
	PKG_HASH:=skip
else ifeq ($(ARCH),x86_64)
	TUIC_ARCH:=$(TUIC_TYPE)-x86_64-$(TUIC_FOOT)
	PKG_HASH:=skip
# Set the default value to make OpenWrt Package Checker happy
else
  PKG_SOURCE:=dummy
  PKG_HASH:=skip
endif

define Download/tuic-client
	URL:=https://github.com/EAimTY/tuic/releases/download/$(TUIC_TYPE)/
	URL_FILE:=$(TUIC_ARCH)
	FILE:=$(TUIC_ARCH)
	HASH:=skip
endef

define Package/tuic-client
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=Delicately-TUICed 0-RTT proxy protocol
	URL:=https://github.com/EAimTY/tuic/
	DEPENDS:=@USE_MUSL @(aarch64||arm||i386||x86_64) @!(TARGET_x86_geode||TARGET_x86_legacy)
endef

define Build/Prepare
	$(call Build/Prepare/Default)
ifneq ($(CONFIG_PACKAGE_tuic-client),)
	$(call Download,tuic-client)
endif
endef

define Build/Compile
endef

define Package/tuic-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(DL_DIR)/$(TUIC_ARCH) $(1)/usr/bin/tuic-client
endef

$(eval $(call BuildPackage,tuic-client))