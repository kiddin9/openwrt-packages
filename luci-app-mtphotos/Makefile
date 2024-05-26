

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for MTPhotos
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd +luci-lib-docker

define Package/luci-app-mtphotos/conffiles
/etc/config/mtphotos
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
