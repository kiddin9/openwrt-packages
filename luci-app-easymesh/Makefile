#
#-- Copyright (C) 2021 dz <dingzhong110@gmail.com>
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for easymesh
LUCI_DEPENDS:=+kmod-cfg80211 +batctl-default +kmod-batman-adv +dawn
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-easymesh

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
