# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=daed-next
PKG_VERSION:=2023-12-02-102cb56
CORE_VERSION:=core-$(shell date "+%Y-%m-%d")
PKG_RELEASE:=11

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=null
PKG_SOURCE_URL:=https://github.com/daeuniverse/daed-revived-next.git
PKG_MIRROR_HASH:=skip

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/wing
PKG_BUILD_DEPENDS:=golang/host bpf-headers
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/daeuniverse/dae-wing
GO_PKG_LDFLAGS:= \
	-X '$(GO_PKG)/db.AppDescription=$(PKG_NAME) is a integration solution of dae, API and UI.'
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/db.AppName=$(PKG_NAME) \
	$(GO_PKG)/db.AppVersion=$(PKG_VERSION)-$(CORE_VERSION)
GO_PKG_GCFLAGS:=-l=4

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/daed-next/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=https://github.com/daeuniverse/daed-revived-next
endef

define Package/daed-next
  $(call Package/daed-next/Default)
  TITLE:=daed-next is a backend of dae
  # You need enable KERNEL_DEBUG_INFO_BTF and KERNEL_BPF_EVENTS
  DEPENDS:=$(GO_ARCH_DEPENDS) $(BPF_DEPENDS) \
    +ca-bundle +kmod-sched-core +kmod-sched-bpf +kmod-xdp-sockets-diag +kmod-veth \
    +node +v2ray-geoip +v2ray-geosite +zoneinfo-asia
endef

define Package/daed-next/description
  daed-next is a backend of dae, provides a method to bundle arbitrary
  frontend, dae and geodata into one binary.
endef

define Package/daed-next/conffiles
/etc/daed-next/wing.db
/etc/config/daed-next
endef

define Download/daed-next
  URL:=https://github.com/QiuSimons/luci-app-daed-next/releases/download/daed-web-$(PKG_VERSION)/
  URL_FILE:=daed-web-$(PKG_VERSION).squashfs
  FILE:=daed-web-$(PKG_VERSION).squashfs
  HASH:=skip
endef

define Build/Prepare
	( \
	$(TAR) --strip-components=1 -C $(PKG_BUILD_DIR)/../ -xzf $(DL_DIR)/$(PKG_NAME)-$(PKG_VERSION).tar.gz ; \
	rm -rf $(PKG_BUILD_DIR) && git clone https://github.com/daeuniverse/dae-wing $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/wing ; \
	rm -rf $(PKG_BUILD_DIR)/dae-core && git clone https://github.com/daeuniverse/dae $(PKG_BUILD_DIR)/dae-core ; \
	rm -rf $(PKG_BUILD_DIR)/dae-core/control/kern/headers && git clone https://github.com/daeuniverse/dae_bpf_headers $(PKG_BUILD_DIR)/dae-core/control/kern/headers ; \
	pushd $(PKG_BUILD_DIR)/dae-core ; \
	sed -i -e 's!default:"30s"!default:"600s"!g' -e 's!default:"HEAD"!default:"CONNECT"!g' -e 's!default:"dns.google.com:53,8.8.8.8,2001:4860:4860::8888"!default:"one.one.one.one:53,1.0.0.1,2606:4700:4700::1111"!g' -e 's!default:"http://cp.cloudflare.com,1.1.1.1,2606:4700:4700::1111"!default:"http://cp.cloudflare.com,1.0.0.1,2606:4700:4700::1111"!g' config/config.go ; \
	go get -u=patch ; \
	go mod tidy ; \
	popd ; \
	pushd $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/wing ; \
	wget -qO - https://github.com/daeuniverse/dae-wing/commit/ca0296173d36746335efed1923ff08c1300f7a61.patch | patch -p1 ; \
	go get -u=patch ; \
	go mod tidy ; \
	popd ; \
	)
endef

DAE_CFLAGS:= \
	-O2 -Wall -Werror \
	-DMAX_MATCH_SET_LEN=64 \
	-I$(BPF_HEADERS_DIR)/tools/lib \
	-I$(BPF_HEADERS_DIR)/arch/$(BPF_KARCH)/include/asm/mach-generic

ifneq ($(CONFIG_USE_MUSL),)
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Build/Compile
	( \
		pushd $(PKG_BUILD_DIR) ; \
		$(MAKE) deps ; \
		$(GO_GENERAL_BUILD_CONFIG_VARS) \
		$(GO_PKG_BUILD_CONFIG_VARS) \
		$(GO_PKG_BUILD_VARS) \
		go generate ./... ; \
		cd dae-core ; \
		$(GO_GENERAL_BUILD_CONFIG_VARS) \
		$(GO_PKG_BUILD_CONFIG_VARS) \
		$(GO_PKG_BUILD_VARS) \
		BPF_CLANG="$(CLANG)" \
		BPF_STRIP_FLAG="-strip=$(LLVM_STRIP)" \
		BPF_CFLAGS="$(DAE_CFLAGS)" \
		BPF_TARGET="bpfel,bpfeb" \
		go generate control/control.go ; \
		popd ; \
		$(call GoPackage/Build/Compile) ; \
	)
endef

define Package/daed-next/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dae-wing $(1)/usr/bin/dae-wing

	$(INSTALL_DIR) $(1)/usr/share/daed-next
	$(INSTALL_DATA) $(DL_DIR)/daed-web-$(PKG_VERSION).squashfs $(1)/usr/share/daed-next/daed-web.squashfs

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/daed-next.config $(1)/etc/config/daed-next

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/daed-next.init $(1)/etc/init.d/daed-next
endef

$(eval $(call Download,daed-next))
$(eval $(call GoBinPackage,daed-next))
$(eval $(call BuildPackage,daed-next))
