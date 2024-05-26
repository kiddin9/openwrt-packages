

include $(TOPDIR)/rules.mk


LUCI_TITLE:=LuCI support for SysTools
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+lsblk +docker +dockerd +luci-lib-iform +luci-lib-taskd +speedtestcli
LUCI_EXTRA_DEPENDS:=luci-lib-iform (>=1.1)

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

