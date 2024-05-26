# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dae
PKG_VERSION:=0.5.1
PKG_RELEASE:=48

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://github.com/daeuniverse/dae/releases/download/v$(PKG_VERSION)/dae-full-src.zip?
PKG_HASH:=skip

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host bpf-headers
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/daeuniverse/dae
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/cmd.Version=$(PKG_VERSION) \
	$(GO_PKG)/common/consts.MaxMatchSetLen_=64

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

UNZIP_CMD:=unzip -q -d $(PKG_BUILD_DIR) $(DL_DIR)/$(PKG_SOURCE)

define Package/dae/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=https://github.com/daeuniverse/dae
endef

define Package/dae
  $(call Package/dae/Default)
  TITLE:=A lightweight and high-performance transparent proxy solution
  # You need enable KERNEL_DEBUG_INFO_BTF and KERNEL_BPF_EVENTS
  DEPENDS:=$(GO_ARCH_DEPENDS) $(BPF_DEPENDS)  \
    +ca-bundle +kmod-sched-core +kmod-sched-bpf +kmod-xdp-sockets-diag \
    +kmod-veth
endef

define Package/dae-geoip
  $(call Package/dae/Default)
  TITLE:=geoip for dae
  DEPENDS:=+dae +v2ray-geoip
  PKGARCH:=all
endef

define Package/dae-geosite
  $(call Package/dae/Default)
  TITLE:=geosite for dae
  DEPENDS:=+dae +v2ray-geosite
  PKGARCH:=all
endef

define Package/dae/description
  dae, means goose, is a lightweight and high-performance transparent
  proxy solution.

  In order to improve the traffic diversion performance as much as possible,
  dae runs the transparent proxy and traffic diversion suite in the linux
  kernel by eBPF. Therefore, we have the opportunity to make the direct
  traffic bypass the forwarding by proxy application and achieve true direct
  traffic through. Under such a magic trick, there is almost no performance
  loss and additional resource consumption for direct traffic.
endef

define Package/dae/conffiles
/etc/dae/config.dae
/etc/config/dae
endef

DAE_CFLAGS:= \
	-O2 -Wall -Werror \
	-DMAX_MATCH_SET_LEN=64 \
	-I$(BPF_HEADERS_DIR)/tools/lib \
	-I$(BPF_HEADERS_DIR)/arch/$(BPF_KARCH)/include/asm/mach-generic

define Build/Compile
	( \
		$(GO_GENERAL_BUILD_CONFIG_VARS) \
		$(GO_PKG_BUILD_CONFIG_VARS) \
		$(GO_PKG_BUILD_VARS) \
		BPF_CLANG="$(CLANG)" \
		BPF_STRIP_FLAG="-strip=$(LLVM_STRIP)" \
		BPF_CFLAGS="$(DAE_CFLAGS)" \
		BPF_TARGET="bpfel,bpfeb" \
		go generate $(PKG_BUILD_DIR)/control/control.go ; \
		$(call GoPackage/Build/Compile) ; \
	)
endef

define Package/dae/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/dae/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/example.dae $(1)/etc/dae/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/dae.config $(1)/etc/config/dae

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/dae.init $(1)/etc/init.d/dae
endef

define Package/dae-geoip/install
	$(INSTALL_DIR) $(1)/usr/share/dae
	$(LN) ../v2ray/geoip.dat $(1)/usr/share/dae/geoip.dat
endef

define Package/dae-geosite/install
	$(INSTALL_DIR) $(1)/usr/share/dae
	$(LN) ../v2ray/geosite.dat $(1)/usr/share/dae/geosite.dat
endef

$(eval $(call GoBinPackage,dae))
$(eval $(call BuildPackage,dae))
$(eval $(call BuildPackage,dae-geoip))
$(eval $(call BuildPackage,dae-geosite))
