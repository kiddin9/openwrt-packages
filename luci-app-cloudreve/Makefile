# Copyright (C) 2019 Openwrt.org
#
# This is a free software, use it under Apache Licene 2.0 & GNU General Public License v3.0.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Cloudreve for LuCI
LUCI_DEPENDS:=+cloudreve
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-cloudreve

define Package/luci-app-cloudreve/conffiles
/etc/config/cloudreve
/etc/cloudreve/
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
