

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for bmtedge
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-bmtedge/conffiles
/etc/config/bmtedge
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
