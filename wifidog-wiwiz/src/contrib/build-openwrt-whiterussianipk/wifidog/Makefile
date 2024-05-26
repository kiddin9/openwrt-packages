# $Id: $
ifndef TOPDIR
	        ERR := $(Please set TOPDIR to OpenWRT SDK's buildroot)
endif

include $(TOPDIR)/rules.mk

PKG_NAME:=wifidog
PKG_VERSION:=20090925
PKG_RELEASE:=1
PKG_MD5SUM:=

PKG_SOURCE_URL:= @SF/$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_CAT:=zcat
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install
include $(TOPDIR)/package/rules.mk
$(eval $(call PKG_template,WIFIDOG,$(PKG_NAME),$(PKG_VERSION)-$(PKG_RELEASE),$(ARCH)))
$(PKG_BUILD_DIR)/.configured: $(PKG_BUILD_DIR)/.prepared
	(cd $(PKG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
		LDFLAGS="-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib" \
		./configure \
			--target=$(GNU_TARGET_NAME) \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--prefix=/usr \
			--sysconfdir=/etc \
			--without-libiconv-prefix \
			--without-libintl-prefix \
			--disable-nls \
	);
	## Add software specific configurable options above
	## See : ./configure --help
	touch $@

$(PKG_BUILD_DIR)/.built:
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
	touch $@

$(IPKG_WIFIDOG):
	install -m0755 -d $(IDIR_WIFIDOG)/etc/init.d
	install -m0755 ./files/$(PKG_NAME).init $(IDIR_WIFIDOG)/etc/init.d/S65wifidog
	install -m0644 ./files/wifidog.conf $(IDIR_WIFIDOG)/etc/
	install -m0644 $(PKG_BUILD_DIR)/wifidog-msg.html $(IDIR_WIFIDOG)/etc/
	install -m0755 -d $(IDIR_WIFIDOG)/usr/bin
	install -m0755 -d $(IDIR_WIFIDOG)/usr/lib
	install -m0755 $(PKG_BUILD_DIR)/scripts/init.d/wifidog $(IDIR_WIFIDOG)/usr/bin/wifidog-init
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/wifidog $(IDIR_WIFIDOG)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/wdctl $(IDIR_WIFIDOG)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhttpd.so* $(IDIR_WIFIDOG)/usr/lib/
	$(RSTRIP) $(IDIR_WIFIDOG)
	$(IPKG_BUILD) $(IDIR_WIFIDOG) $(PACKAGE_DIR)
mostlyclean:
	make -C $(PKG_BUILD_DIR) clean
	rm $(PKG_BUILD_DIR)/.built
all: $(IPKG_WIFIDOG)