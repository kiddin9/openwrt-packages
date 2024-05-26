

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for ChineseSubFinder
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-chinesesubfinder/conffiles
/etc/config/chinesesubfinder
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
