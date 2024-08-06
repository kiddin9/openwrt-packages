include $(TOPDIR)/rules.mk

PKG_NAME:=hickory-dns
PKG_VERSION:=master
PKG_RELEASE:=9

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/hickory-dns/hickory-dns.git
PKG_SOURCE_VERSION:=1c7ec9e3ab88015d76a1d89cd61a497f3f6e39d1
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
