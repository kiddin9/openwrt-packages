include $(TOPDIR)/rules.mk

PKG_NAME:=ookla-speedtest
PKG_VERSION:=1.2.0
PKG_RELEASE:=3
PKG_MAINTAINER:=Konstantine Shevlakov <shevlakov@132lan.ru>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  TITLE:=Speedtest from Ookla
  SECTION:=net
  CATEGORY:=Network
endef

ifeq ($(ARCH),x86_64)
  BIN_PATH:=./files/x86_64
endif
ifeq ($(ARCH),i386)
  BIN_PATH:=./files/i386
endif
ifeq ($(ARCH),arm)
  BIN_PATH:=./files/armhf
endif
ifeq ($(ARCH),aarch64)
  BIN_PATH:=./files/aarch64
endif

define Package/$(PKG_NAME)/description
	Speedtest CLI brings the trusted technology and global server network behind Speedtest to the command line.
	Built for software developers, system administrators and computer enthusiasts alike,
	Speedtest CLI is the first official Linux-native Speedtest application backed by Ookla®.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(BIN_PATH)/speedtest $(1)/usr/bin
endef

$(eval $(call BuildPackage,$(PKG_NAME))) 
