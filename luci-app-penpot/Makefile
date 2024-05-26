

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for Penpot
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd +docker-compose

define Package/luci-app-penpot/conffiles
/etc/config/penpot
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
