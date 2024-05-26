# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

ifeq ($(ARCH),aarch64)
  PKG_ARCH_VERYSYNC:=arm64
  PKG_HASH_VERYSYNC:=f4461b26fd4bd56043b1bbb8c3156265bad41a1c53ab3853eb18b241657c5532
else ifeq ($(ARCH),arm)
  PKG_ARCH_VERYSYNC:=arm
  PKG_HASH_VERYSYNC:=c3b7225594f09023c03ad8ded788c49c5ef0757cc4aaf50677a9c335da4f1512
else ifeq ($(ARCH),i386)
  PKG_ARCH_VERYSYNC:=386
  PKG_HASH_VERYSYNC:=1c5b3d8bb79dcda9f2688f4b431a5e2a2aa3898ad399a09f6901a68dc545c104
else ifeq ($(ARCH),mips)
  PKG_ARCH_VERYSYNC:=mips
  PKG_HASH_VERYSYNC:=fb40b2231f8f6b8175384b88205ba47c07aab58c950f66f081c5453e7d439d73
else ifeq ($(ARCH),mipsel)
  PKG_ARCH_VERYSYNC:=mipsle
  PKG_HASH_VERYSYNC:=7b419af7e96522920e51f79a2d0dd26d67234ffeb7e1d739f11a129abf6eef62
else ifeq ($(ARCH),powerpc64)
  PKG_ARCH_VERYSYNC:=ppc64
  PKG_HASH_VERYSYNC:=9042eed13c00d3e35a3ac81b3a0f4738f8452ee14db7f7bcad4e058706447401
else ifeq ($(ARCH),x86_64)
  PKG_ARCH_VERYSYNC:=amd64
  PKG_HASH_VERYSYNC:=ccd1c64e6f3bb96a71870b6881b391dc4b02f929180f2874856dfe588da21f14
endif

PKG_NAME:=verysync
PKG_VERSION:=2.17.0
PKG_RELEASE:=24

PKG_SOURCE:=$(PKG_NAME)-linux-$(PKG_ARCH_VERYSYNC)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://dl.verysync.com/releases/v$(PKG_VERSION)/ \
		http://dl-cn.verysync.com/releases/v$(PKG_VERSION)/
PKG_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-linux-$(PKG_ARCH_VERYSYNC)-v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/verysync
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A efficient data transmission tool
  URL:=http://www.verysync.com
  DEPENDS:=@(aarch64||arm||i386||mips||mipsel||powerpc64||x86_64)
endef

define Build/Compile
endef

define Package/verysync/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/verysync $(1)/usr/bin/verysync
endef

$(eval $(call BuildPackage,verysync))
