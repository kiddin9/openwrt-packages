

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for runmynas
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+docker +dockerd +luci-lib-iform +luci-lib-taskd
LUCI_EXTRA_DEPENDS:=luci-lib-iform (>=1.1)

define Package/luci-app-runmynas/conffiles
/etc/config/runmynas
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

