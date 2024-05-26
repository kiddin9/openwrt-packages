include $(TOPDIR)/rules.mk

PKG_NAME:=webdav2
PKG_VERSION:=4.3.1
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jjm2473/webdav/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=jjm2473 <jjm2473@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/hacdias/webdav

GO_PKG_LDFLAGS_X:= \
  github.com/hacdias/webdav/cmd.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)

define Package/webdav2
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=File Transfer
	TITLE:=Simple Go WebDAV server.
	URL:=https://github.com/hacdias/webdav
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/webdav2/description
 A Simple Go WebDAV server that supports acls.
endef

define Package/webdav2/conffiles
/etc/config/webdav2
endef

define Package/webdav2/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/webdav $(1)/usr/sbin/webdav2
	$(INSTALL_CONF) ./files/webdav2.config $(1)/etc/config/webdav2
	$(INSTALL_BIN) ./files/webdav2.init $(1)/etc/init.d/webdav2
endef

$(eval $(call GoBinPackage,webdav2))
$(eval $(call BuildPackage,webdav2))
