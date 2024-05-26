

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for Owntone
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-owntone/conffiles
/etc/config/owntone
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
