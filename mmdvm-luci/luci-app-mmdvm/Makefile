# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for MMDVM
LUCI_DEPENDS:=+luci-theme-bootstrap-mmdvm +mmdvm-host
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
