# SPDX-License-Identifier: Apache-2.0
#
# Copyright (C) 2024 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

LUCI_TITLE:=LuCI app for dae
LUCI_DEPENDS:=+dae +dae-geoip +dae-geosite

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
