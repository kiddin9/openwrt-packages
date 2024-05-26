# Copyright (C) 2020-2022 Hyy2001X <https://github.com/Hyy2001X>
# See more information at https://webd.cf/

include $(TOPDIR)/rules.mk

PKG_NAME:=webd
PKG_VERSION:=20240302
PKG_RELEASE:=5

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=A Lightweight self-hosted netdisk application
	DEPENDS:=@(arm||x86_64||mipsel||mips||aarch64)
	URL:=https://webd.cf
endef

ifeq ($(ARCH),x86_64)
	TARGET_ARCH:=x86_64
	TARGET_BOARD:=musl
endif

ifeq ($(ARCH),mipsel)
	TARGET_ARCH:=mipsel
	ifeq ($(BOARD),bcm47xx)
		TARGET_BOARD:=musl.brcm47xx-mips74k
	endif
	ifeq ($(BOARD),ramips)
		TARGET_BOARD:=musl.ramips-mt7620
	endif
endif

ifeq ($(ARCH),mips)
	TARGET_ARCH:=mips
	ifeq ($(BOARD),ath79)
		TARGET_BOARD:=musl.ath79
	endif
	ifeq ($(BOARD),bcm63xx)
		TARGET_BOARD:=uclibc.brcm63xx
	endif
	ifeq ($(BOARD),ar71xx)
		TARGET_BOARD:=uclibc.ar71xx
	endif
endif

ifeq ($(ARCH),arm)
	TARGET_ARCH:=arm
	ifeq ($(BOARD),ipq806x)
		TARGET_BOARD:=muslgnueabi.ipq806x
	endif
	ifeq ($(BOARD),ipq40xx)
		TARGET_BOARD:=muslgnueabi.ipq40xx
	endif
	ifeq ($(BOARD),bcm53xx)
		TARGET_BOARD:=muslgnueabi.bcm53xx
	endif
	ifeq ($(BOARD),oxnas)
		TARGET_BOARD:=muslgnueabi.oxnas
	endif
	ifeq ($(BOARD),kirkwood)
		TARGET_BOARD:=muslgnueabi.kirkwood
	endif
	ifeq ($(BOARD),mvebu)
		TARGET_BOARD:=muslgnueabi.mvebu-cortexa9
	endif
endif

ifeq ($(ARCH),aarch64)
	TARGET_ARCH:=aarch64
	ifeq ($(BOARD),cortex-a53)
		TARGET_BOARD:=musl.brcm2708-bcm2710
	endif
	ifeq ($(BOARD),rockchip)
		TARGET_BOARD:=musl.rockchip-armv8
	endif
endif

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(TARGET_ARCH)-openwrt-linux-$(TARGET_BOARD).tar.gz
PKG_SOURCE_URL:=https://cnt2.cf/webd/$(PKG_VERSION)/
PKG_HASH:=skip

UNTAR_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

define Build/Prepare
	mkdir -p $(UNTAR_DIR)
	tar -zxvf $(DL_DIR)/$(PKG_SOURCE) -C $(UNTAR_DIR)
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(UNTAR_DIR)/webd/webd $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)
	$(INSTALL_BIN) $(UNTAR_DIR)/webd/web/.player.htm $(1)/usr/share/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) $(UNTAR_DIR)/webd/webd.conf $(1)/etc/webd.conf.example
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
