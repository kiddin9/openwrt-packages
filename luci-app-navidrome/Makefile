

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for Navidrome
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-navidrome/conffiles
/etc/config/navidrome
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
