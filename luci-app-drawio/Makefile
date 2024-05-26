

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for DrawIO
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd +luci-lib-docker +docker-compose

define Package/luci-app-drawio/conffiles
/etc/config/drawio
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
