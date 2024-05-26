

include $(TOPDIR)/rules.mk

PKG_MAINTAINER:=jjm2473 <jjm2473@gmail.com>

LUCI_TITLE:=LuCI realtime client bandwidth monitor
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+iptables

define Package/luci-app-rtbwmon/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    /usr/libexec/rtbwmon.sh prerm
fi
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
