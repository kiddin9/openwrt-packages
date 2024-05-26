# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=filebrowser
PKG_VERSION:=2.23.0
PKG_RELEASE:=70

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/filebrowser/filebrowser/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host node/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/filebrowser/filebrowser/v2
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/version.CommitSHA=$(PKG_VERSION) \
	$(GO_PKG)/version.Version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/filebrowser
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Web File Browser
  URL:=https://github.com/filebrowser/filebrowser
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/filebrowser/description
  filebrowser provides a file managing interface within a specified directory
  and it can be used to upload, delete, preview, rename and edit your files.
  It allows the creation of multiple users and each user can have its own directory.
  It can be used as a standalone app or as a middleware.
endef

define Package/filebrowser/conffiles
/etc/filebrowser/
/etc/config/filebrowser
endef

define Build/Compile
	( \
		pushd "$(PKG_BUILD_DIR)/frontend" ; \
		npm ci; \
		NODE_OPTIONS=--openssl-legacy-provider npm run build ; \
		popd ; \
		$(call GoPackage/Build/Compile) ; \
	)
endef

define Package/filebrowser/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/filebrowser.config $(1)/etc/config/filebrowser
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/filebrowser.init $(1)/etc/init.d/filebrowser
endef

$(eval $(call GoBinPackage,filebrowser))
$(eval $(call BuildPackage,filebrowser))
