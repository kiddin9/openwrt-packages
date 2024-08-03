include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-mosdns

LUCI_TITLE:=LuCI Support for mosdns
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+mosdns +jsonfilter +curl +v2ray-geoip +v2ray-geosite +v2dat

PKG_MAINTAINER:=sbwml <admin@cooluc.com>

define Package/$(PKG_NAME)/conffiles
/etc/config/mosdns
/etc/mosdns/cache.dump
/etc/mosdns/config_custom.yaml
/etc/mosdns/rule
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
