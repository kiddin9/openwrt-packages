# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI app for dae dashboard
LUCI_DEPENDS:=+daed +daed-geoip +daed-geosite
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
