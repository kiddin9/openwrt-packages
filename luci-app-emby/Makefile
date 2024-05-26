

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for Emby
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-emby/conffiles
/etc/config/emby
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
