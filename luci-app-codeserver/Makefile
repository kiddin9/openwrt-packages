

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for CodeServer
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-codeserver/conffiles
/etc/config/codeserver
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
