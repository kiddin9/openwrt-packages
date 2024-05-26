#
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ircddb-gateway
PKG_VERSION:=1.3.1
PKG_RELEASE:=4
PKG_REV:=380c094
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/lazywalker/ircDDBGateway
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=null
PKG_SOURCE_PROTO:=git
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Michael BD7MQB <bd7mqb@qq.com>

PKG_CHECK_FORMAT_SECURITY:=0
PKG_RELEASE:=4
PKG_INSTALL:=1
include $(INCLUDE_DIR)/package.mk

define Package/${PKG_NAME}
	SECTION:=net
	CATEGORY:=MMDVM
	TITLE:=ircDDBGateway
	URL:=https://github.com/g4klx/ircDDBGateway
	DEPENDS:=+libwxwidgets
endef

DEPENDS:=+libwxwidgets
define Package/${PKG_NAME}/description
The ircDDB Gateway for D-Star
endef

TARGET_LIBS = -Wl,-lwx_baseu-3.0 -lwx_baseu_net-3.0 -lwx_baseu_xml-3.0

TARGET_LDFLAGS = -L$(STAGING_DIR)/usr/lib

DATADIR := "/etc/mmdvm/ircddbgateway"

# TARGET_CFLAGS = -O2 -Wall -fPIC \
# 	-DwxDEBUG_LEVEL=0 \
# 	-DwxUSE_SELECT_DISPATCHER=1 \
#  	-DwxHAS_INOTIFY=1 \
# 	-DWXWIN_COMPATIBILITY_2_8=1 \
#  	-DLOG_DIR='$(LOGDIR)' -DCONF_DIR='$(CONFDIR)' -DDATA_DIR='$(DATADIR)'

MAKE_FLAGS +=\
	LDFLAGS="$(TARGET_LDFLAGS)" \
	LIBS="$(TARGET_LIBS)" \

define Package/${PKG_NAME}/install
	$(INSTALL_DIR) $(1)$(DATADIR)
	$(INSTALL_DIR) $(1)/usr/bin

	$(CP) $(PKG_BUILD_DIR)/TimeServer/timeserverd $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/ircDDBGateway/ircddbgatewayd $(1)/usr/bin/
	$(CP) $(PKG_BUILD_DIR)/Data/* $(1)$(DATADIR)/
	$(CP) -a files/* $(1)/
endef

$(eval $(call BuildPackage,${PKG_NAME}))
