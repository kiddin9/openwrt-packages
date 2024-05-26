# Author: mingxiaoyu (fengying0347@163.com)
#
# Licensed to the public under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-cloudflarespeedtest

LUCI_TITLE:=LuCI support for Cloudflares Speed Test
LUCI_DEPENDS:=+cdnspeedtest +openssl-util +curl
LUCI_PKGARCH:=all
PKG_LICENSE:=AGPL-3.0
PKG_MAINTAINER:=mingxiaoyu <fengying0347@163.com>

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

