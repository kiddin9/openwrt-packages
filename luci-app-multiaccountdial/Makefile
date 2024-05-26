#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=multi account Virtual WAN config generator
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+kmod-macvlan +luci-app-mwan3


define Package/luci-app-multiaccountdial/conffiles
/etc/config/multiaccountdial
/etc/multiaccountdial/config
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
