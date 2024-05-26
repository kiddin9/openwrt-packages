

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for homeassistant
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-taskd

define Package/luci-app-homeassistant/conffiles
/etc/config/homeassistant
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
