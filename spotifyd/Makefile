include $(TOPDIR)/rules.mk

PKG_NAME:=spotifyd
PKG_VERSION:=0.3.5
PKG_RELEASE:=4

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Spotifyd/spotifyd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/spotifyd
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=A spotify daemon
  DEPENDS:=$(RUST_ARCH_DEPENDS) @!(mips||mipsel) +alsa-lib
  URL:=https://spotifyd.rs/
endef

define Package/spotifyd/description
  An open source Spotify client running as a UNIX daemon.

  Spotifyd streams music just like the official client, but is more
  lightweight and supports more platforms. Spotifyd also supports the
  Spotify Connect protocol, which makes it show up as a device that
  can be controlled from the official clients.
endef

define Package/spotifyd/conffiles
/etc/config/spotifyd
endef

define Package/spotifyd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/spotifyd $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/spotifyd.config $(1)/etc/config/spotifyd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/spotifyd.init $(1)/etc/init.d/spotifyd
endef

$(eval $(call RustBinPackage,spotifyd))
$(eval $(call BuildPackage,spotifyd))
