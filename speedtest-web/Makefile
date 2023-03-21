#
# Copyright (C) 2021 ZeakyX
#

include $(TOPDIR)/rules.mk

PKG_NAME:=speedtest-web
PKG_VERSION:=1.1.5
PKG_RELEASE:=5

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ZeaKyX/speedtest-go.git
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=LGPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_SPEEDTEST_WEB_COMPRESS_GOPROXY \
	CONFIG_SPEEDTEST_WEB_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/librespeed/speedtest
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.VersionString=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/speedtest-web/config
config SPEEDTEST_WEB_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config SPEEDTEST_WEB_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

ifeq ($(CONFIG_SPEEDTEST_WEB_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/speedtest-web
  SECTION:=net
  CATEGORY:=Network
  TITLE:=speedtest-web is a Openwrt package for speedtest-go, a Go backend for LibreSpeed
  URL:=https://github.com/librespeed/speedtest-go
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/speedtest-web/description
	speedtest-web is a Openwrt package for speedtest-go, a Go backend for LibreSpeed
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_SPEEDTEST_WEB_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/speedtest
endif
endef

define Package/speedtest-web/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/speedtest $(1)/usr/bin/$(PKG_NAME)
endef

$(eval $(call GoBinPackage,speedtest-web))
$(eval $(call BuildPackage,speedtest-web))
