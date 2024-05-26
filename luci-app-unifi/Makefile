

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for UnifiController
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-unifi/conffiles
/etc/config/unifi
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
