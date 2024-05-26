#
# Copyright (C) 2018-2019 Ycarus (Yannick Chabanois) <ycarus@zugaina.org>
#
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI SNMPD Interface
LUCI_DEPENDS:=+snmpd +snmptrapd +snmp-utils +snmp-mibs

PKG_LICENSE:=GPLv3

#include ../luci/luci.mk
include $(TOPDIR)/feeds/luci/luci.mk
# call BuildPackage - OpenWrt buildroot signature
