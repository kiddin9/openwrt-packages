#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Antitethering module for luci-app-firewall
LUCI_DEPENDS:= +luci-app-firewall +iptables-mod-ipopt +kmod-ipt-ipopt

PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
