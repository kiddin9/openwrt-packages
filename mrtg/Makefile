#
# Copyright (C) 2011-2012 OpenWrt.org
# Copyright (C) 2011 Paolo Pisati <p.pisati@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mrtg
PKG_VERSION:=2.17.10
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://oss.oetiker.ch/mrtg/pub/
PKG_MD5SUM:=skip

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/mrtg
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libgd +libpng +zlib +perl +perlbase-essential +perlbase-findbin \
    +perlbase-cwd +perlbase-config +perlbase-file +perlbase-getopt \
    +perlbase-math +perlbase-integer +perlbase-xsloader +perlbase-pod \
    +perlbase-universal +perlbase-socket +perlbase-posix +perlbase-autoloader \
    +perlbase-fcntl +perlbase-tie +perlbase-io +perlbase-symbol \
    +perlbase-selectsaver +perlbase-errno +perlbase-scalar +perlbase-list \
	+perlbase-base +perlbase-storable
  TITLE:=The Multi Router Traffic Grapher
  URL:=http://oss.oetiker.ch/mrtg/index.en.html
endef

define Package/mrtg/description
  The Multi Router Traffic Grapher, or just simply MRTG, is free software for
  monitoring and measuring the traffic load on network links. It allows the
  user to see traffic load on a network over time in graphical form. It was
  originally developed by Tobias Oetiker and Dave Rand to monitor router
  traffic, but has developed into a tool that can create graphs and statistics
  for almost anything.
endef

define Package/mrtg/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/share/* $(1)/usr/share/
endef

$(eval $(call BuildPackage,mrtg))
