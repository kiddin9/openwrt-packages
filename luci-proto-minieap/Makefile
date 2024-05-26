include $(TOPDIR)/rules.mk

PKG_NAME:=luci-proto-minieap
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

LUCI_TITLE:=LuCI support for MiniEAP
LUCI_DEPENDS:=+minieap
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
