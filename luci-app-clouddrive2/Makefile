

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for CloudDrive2
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+mount-utils +lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-clouddrive2/conffiles
/etc/config/clouddrive2
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

