

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for Xunlei
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-xunlei/conffiles
/etc/config/xunlei
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
