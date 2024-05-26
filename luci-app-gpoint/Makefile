include $(TOPDIR)/rules.mk

LUCI_TITLE:=GNSS Information dashboard for 3G/LTE dongle
LUCI_DEPENDS:=+lua +luci-compat +curl +lua-rs232 +luasocket +iwinfo +libiwinfo-lua +lua-bit32 +usbutils +gpsd
PKG_LICENSE:=GPLv3

define Package/luci-app-gpoint/postrm
	rm -f /etc/config/gpoint
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
