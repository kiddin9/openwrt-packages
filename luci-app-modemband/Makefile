#
# Copyright 2022-2024 Rafał Wabik - IceG - From eko.one.pl forum
# 
# MIT License
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-modemband
LUCI_TITLE:=LuCI JS Support for modemband application
MAINTAINER:=Rafał Wabik <4Rafal@gmail.com>
LUCI_DESCRIPTION:=LuCI JS interface for the modemband. The package allows set LTE/5G bands for selected 4G/5G modems.
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+sms-tool +modemband

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
