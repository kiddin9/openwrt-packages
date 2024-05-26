#
# Copyright (C) 2019-2024 The Sirpdboy Team <herboy2008@gmail.com>    
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk
THEME_NAME:=kucat
THEME_TITLE:=Kucat Theme
PKG_NAME:=luci-theme-$(THEME_NAME)
LUCI_TITLE:=Kucat Theme by sirpdboy
LUCI_DEPENDS:=

define Package/luci-theme-$(THEME_NAME)/postinst
#!/bin/sh

rm -Rf /var/luci-modulecache
rm -Rf /var/luci-indexcache
exit 0

endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
