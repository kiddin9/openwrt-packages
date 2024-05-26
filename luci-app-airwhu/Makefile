include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-airwhu
PKG_VERSION=1.0

LUCI_TITLE:=LuCI web-interface for Ruijie 802.1X Client with IPv6 NAT
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+mentohust +kmod-ipt-nat6

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
