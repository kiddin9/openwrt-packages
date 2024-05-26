

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for PhotoPrism
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-photoprism/conffiles
/etc/config/photoprism
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
