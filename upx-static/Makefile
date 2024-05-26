# Copyright (C) 2020-2022 Hyy2001X <https://github.com/Hyy2001X>

include $(TOPDIR)/rules.mk

PKG_NAME:=upx-static
PKG_VERSION:=3.96
PKG_RELEASE:=3

ifeq ($(ARCH),x86_64)
	PKG_ARCH:=amd64
endif
ifeq ($(ARCH),i386)
	PKG_ARCH:=i386
endif
ifeq ($(ARCH),mipsel)
	PKG_ARCH:=mipsel
endif
ifeq ($(ARCH),mips)
	PKG_ARCH:=mips
endif
ifeq ($(ARCH),armeb)
	PKG_ARCH:=armeb
endif
ifeq ($(ARCH),arm)
	PKG_ARCH:=arm
endif
ifeq ($(ARCH),arm64)
	PKG_ARCH:=arm64
endif
ifeq ($(ARCH),powerpc)
	PKG_ARCH:=powerpc
endif
ifeq ($(ARCH),powerpc64)
	PKG_ARCH:=powerpc64le
endif

PKG_FILE:=upx-$(PKG_VERSION).tar.xz
PKG_URL:=https://github.com/upx/upx/releases/download/v$(PKG_VERSION)/upx-$(PKG_VERSION)-$(PKG_ARCH)_linux.tar.xz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SUBMENU:=Compression
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=UPX - The Ultimate Packer for eXecutables
	URL:=https://upx.github.io
endef

define Package/$(PKG_NAME)/description
UPX - The Ultimate Packer for eXecutables
endef

define Build/Prepare
	if [ ! -f $(DL_DIR)/$(PKG_FILE) ] ; then \
		wget -q $(PKG_URL) -O $(DL_DIR)/$(PKG_FILE); \
	fi
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	xz -d -c $(DL_DIR)/$(PKG_FILE) | tar -x -C $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/upx-$(PKG_VERSION)-$(PKG_ARCH)_linux/upx $(1)/bin/upx
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
