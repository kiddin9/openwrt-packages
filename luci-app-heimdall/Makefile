

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for heimdall
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+docker +dockerd +luci-lib-taskd

define Package/luci-app-heimdall/conffiles
/etc/config/heimdall
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
