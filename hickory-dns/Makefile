include $(TOPDIR)/rules.mk

PKG_NAME:=hickory-dns
PKG_VERSION:=master
PKG_RELEASE:=8

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/hickory-dns/hickory-dns.git
PKG_SOURCE_VERSION:=e8850b788b5d10279998feb4b74ce3ffbcd1b9d6
PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

PKG_BUILD_FLAGS:=no-lto
RUST_PKG_FEATURES:=resolver,dns-over-https-rustls,dns-over-quic,dns-over-h3,native-certs,dnssec-ring,recursor

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/hickory-dns
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=A plug-in DNS forwarder/splitter
  URL:=https://github.com/hickory-dns/hickory-dns
  DEPENDS:=$(RUST_ARCH_DEPENDS)
endef

define Build/Compile
  $(call Build/Compile/Cargo,bin,--no-default-features)
endef

define Package/hickory-dns/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/hickory-dns/
	$(INSTALL_BIN) ./files/etc/init.d/hickory-dns $(1)/etc/init.d/hickory-dns
	$(INSTALL_BIN) ./files/etc/hickory-dns/forwarder.toml $(1)/etc/hickory-dns/forwarder.toml
endef

$(eval $(call RustBinPackage,hickory-dns))
$(eval $(call BuildPackage,hickory-dns))
