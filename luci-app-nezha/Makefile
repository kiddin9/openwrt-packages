#
# <https://github.com/Erope/openwrt_nezha/>
# 
# Copyright (C) 2021 zPonds <admin@shinenet.cn>
# Copyright (C) 2020 KFERMercer <KFER.Mercer@gmail.com>
# Copyright (C) 2020 [CTCGFW] Project OpenWRT
# 
# THIS IS FREE SOFTWARE, LICENSED UNDER GPLv3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-nezha-agent
LUCI_TITLE:=LuCI support for nezha agent
LUCI_DEPENDS:=+nezha-agent
LUCI_PKGARCH:=all
PKG_MAINTAINER:=<https://github.com/Erope/openwrt_nezha/>

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
