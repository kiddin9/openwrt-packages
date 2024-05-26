include $(TOPDIR)/rules.mk

PKG_NAME:=homebox
PKG_VERSION:=0.0.0-dev.2020062901
PKG_RELEASE:=18

PKG_SOURCE_URL_FILE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/XGHeaven/homebox/archive/refs/tags/
PKG_HASH:=skip

PKG_BUILD_DEPENDS:=golang/host homebox/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/${PKG_NAME}

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=A Toolbox for Home Local Networks
  URL:=https://github.com/XGHeaven/homebox
  DEPENDS:=$(GO_ARCH_DEPENDS)
  MENU:=1
endef

define Package/$(PKG_NAME)/description
  A Toolbox for Home Local Networks Speed Test
endef

GO_PKG_BUILD_VARS += GO111MODULE=auto
TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Build/Configure
	( \
		cd $(PKG_BUILD_DIR)/server; \
		$(GO_PKG_VARS) \
		go get -d -modcacherw; \
	)
	( \
		cd $(PKG_BUILD_DIR)/server; \
		GOPATH=$(PKG_BUILD_DIR)/.go_work/build \
		go install -modcacherw github.com/go-bindata/go-bindata/...@latest; \
	)
endef

define Build/Compile
	rm -rf $(PKG_BUILD_DIR)/build/static
	mkdir -p $(PKG_BUILD_DIR)/build
	$(CP) $(HOST_BUILD_DIR)/build/static $(PKG_BUILD_DIR)/build/
	( \
		cd $(PKG_BUILD_DIR); \
		$(GO_PKG_VARS) PATH=$(PKG_BUILD_DIR)/.go_work/build/bin:$$$$PATH \
		$(MAKE) build-server; \
	)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/config $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/server $(1)/usr/bin/homebox
	$(INSTALL_CONF) ./files/homebox.config $(1)/etc/config/homebox
	$(INSTALL_BIN) ./files/homebox.init $(1)/etc/init.d/homebox
	$(INSTALL_BIN) ./files/homebox.uci-default $(1)/etc/uci-defaults/homebox
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/homebox
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	[ -f /etc/uci-defaults/homebox ] && /etc/uci-defaults/homebox && rm -f /etc/uci-defaults/homebox
fi
endef

define Host/Configure
	cd $(HOST_BUILD_DIR)/web && rm -f package-lock.json && npm --cache-min 1440 install
endef

define Host/Compile
	cd $(HOST_BUILD_DIR) && $(MAKE) build-web
endef

define Host/Install
endef

define Host/Clean
	rm -f $(HOST_BUILD_DIR)/build/static
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,homebox))
