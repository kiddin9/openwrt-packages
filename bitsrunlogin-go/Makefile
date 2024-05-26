# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=BitSrunLoginGo
PKG_VERSION:=1.5.2
PKG_RELEASE:=21

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Mmx233/BitSrunLoginGo/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/Mmx233/BitSrunLoginGo
GO_PKG_BUILD_PKG:=github.com/Mmx233/BitSrunLoginGo/cmd/bitsrun/

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/bitsrunlogin-go
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Campus Network
  TITLE:=Bit Srun auto login tool
  URL:=https://github.com/Mmx233/BitSrunLoginGo
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/bitsrunlogin-go/conffiles
/etc/config/bitsrunlogin-go
endef

define Package/bitsrunlogin-go/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/bitsrun $(1)/usr/bin/bitsrunlogin-go

	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) $(CURDIR)/files/bitsrunlogin-go.config $(1)/etc/config/bitsrunlogin-go
	$(INSTALL_BIN) $(CURDIR)/files/bitsrunlogin-go.init $(1)/etc/init.d/bitsrunlogin-go
endef

$(eval $(call GoBinPackage,bitsrunlogin-go))
$(eval $(call BuildPackage,bitsrunlogin-go))
