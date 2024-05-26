#
# Copyright (C) 2006-2016 OpenWrt.org
# Copyright (C) 2016 lede-project.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cups
PKG_VERSION:=2.3.3
PKG_RELEASE:=21

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-source.tar.gz
PKG_SOURCE_URL:=https://github.com/apple/cups/releases/download/v$(PKG_VERSION)/
PKG_HASH:=skip

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

STRIP:=true

define Package/cups/Default
  URL:=http://www.cups.org/
  SUBMENU:=Printing
  DEPENDS:=+libcups
endef

define Package/cups
  $(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS+=+libusb-1.0 +libstdcpp
  TITLE:=Common UNIX Printing System (daemon)
endef

define Package/cups/description
  Common UNIX Printing System (daemon)
endef

define Package/cups/conffiles
/etc/cups/classes.conf
/etc/cups/cupsd.conf
/etc/cups/printers.conf
endef

define Package/cups-bsd
  $(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - BSD commands (old)
endef

define Package/cups-client
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS+=+libcupsimage
  TITLE:=Common UNIX Printing System - Client commands
endef

define Package/cups-client/conffiles
/etc/cups/client.conf
endef

define Package/cups-filters
  $(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS+=+libcupsimage
  TITLE:=Common UNIX Printing System - Filter
endef

define Package/cups-ppdc
  $(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS+=+libstdcpp
  TITLE:=Common UNIX Printing System - PPDC utils
endef

define Package/libcups
  $(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libpthread +libpng +libjpeg +zlib
  TITLE:=Common UNIX Printing System - Core library
endef

define Package/libcupsimage
  $(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Common UNIX Printing System - Image library
endef

CONFIGURE_ARGS+= \
	--with-cups-user="nobody" \
	--with-cups-group="nogroup" \
	--with-system-groups="root" \
	--enable-default-shared \
	--enable-shared \
	--enable-libusb \
	--disable-acl \
	--disable-dnssd \
	--disable-dbus \
	--disable-avahi \
	--disable-launchd \
	--disable-pam \
	--disable-slp \
	--disable-gnutls \
	--disable-cdsassl \
	--disable-ssl \
	--disable-gssapi

define Package/cups/install
	$(INSTALL_DIR) $(1)/etc/cups
	$(CP) $(PKG_INSTALL_DIR)/etc/cups/* $(1)/etc/cups/
	$(LN) /tmp $(1)/etc/cups/certs

	$(INSTALL_DIR) $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/backend $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/cgi-bin $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/daemon $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/driver $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/monitor $(1)/usr/lib/cups

	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/{commandtops,pstops} \
		$(PKG_INSTALL_DIR)/usr/lib/cups/filter/gziptoany \
		$(1)/usr/lib/cups/filter

	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/*.tmpl \
		$(1)/usr/share/cups/templates/

	$(INSTALL_DIR) $(1)/usr/share/cups/mime
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/mime/* $(1)/usr/share/cups/mime/

	### Do install docs: cups web interface relies on them
	$(INSTALL_DIR) $(1)/usr/share/doc/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/*.*html \
		$(1)/usr/share/doc/cups/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/*.css \
		$(1)/usr/share/doc/cups/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/*.txt \
		$(1)/usr/share/doc/cups/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/images \
		$(1)/usr/share/doc/cups/

	$(INSTALL_DIR) $(1)/usr/sbin
	# overwrite default config with our own
	$(CP) ./files/etc/cups/* $(1)/etc/cups/

	# install initscript with priority 60
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/cupsd.init $(1)/etc/init.d/cupsd
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/{cupsctl,cupsd} \
		$(1)/usr/sbin/

	# needed for cups to find usb printers per http://wiki.openwrt.org/doc/howto/cups.server
	chmod 700 $(1)/usr/lib/cups/backend/usb
endef

define Package/cups-bsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{lprm,lpq,lpr} $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/lpc $(1)/usr/sbin/
endef

define Package/cups-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/{lp,cancel,cupstestppd} \
		$(PKG_INSTALL_DIR)/usr/bin/{ipptool,lpoptions,lpstat} \
		$(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/{cupsaccept,cupsfilter} \
		$(PKG_INSTALL_DIR)/usr/sbin/{lpadmin,lpinfo,lpmove} \
		$(1)/usr/sbin/
	$(LN) cupsaccept $(1)/usr/sbin/cupsenable
	$(LN) cupsaccept $(1)/usr/sbin/cupsdisable
	$(LN) cupsaccept $(1)/usr/sbin/cupsreject
endef

define Package/cups-filters/install
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/{rastertoepson,rastertohp,rastertolabel,rastertopwg} \
		$(1)/usr/lib/cups/filter
	$(LN) rastertolabel $(1)/usr/lib/cups/filter/rastertodymo
endef

define Package/cups-ppdc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/{ppdc,ppdhtml,ppdi,ppdmerge,ppdpo} \
		$(1)/usr/bin/
endef

define Package/libcups/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcups.so* $(1)/usr/lib/
endef

define Package/libcupsimage/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcupsimage.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cups-config $(2)/bin/

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/cups $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcups*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,cups))
$(eval $(call BuildPackage,libcups))
$(eval $(call BuildPackage,libcupsimage))
$(eval $(call BuildPackage,cups-bsd))
$(eval $(call BuildPackage,cups-client))
$(eval $(call BuildPackage,cups-filters))
$(eval $(call BuildPackage,cups-ppdc))
