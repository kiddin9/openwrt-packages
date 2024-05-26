# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2022  sirpdboy  <herboy2008@gmail.com> https://github.com/sirpdboy/chatgpt-web.git
# 
# This is free software, licensed under the Apache License, Version 2.0 .
#
include $(TOPDIR)/rules.mk

NAME:=chatgpt-web
PKG_NAME:=luci-app-$(NAME)

LUCI_TITLE:=LuCI Support for chatgpt-web Client
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/config/chatgpt-web
endef
include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
