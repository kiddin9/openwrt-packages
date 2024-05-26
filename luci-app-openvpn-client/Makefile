# Copyright (C) 2021-2022 Lienol <lawlienol@gmail.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-openvpn-client

LUCI_TITLE:=LuCI support for OpenVPN Client
LUCI_DEPENDS:=+openvpn-openssl +kmod-tun
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
