# Copyright (C) 2018 XiaoShan mivm.cn

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for k3usb3.0 on or off
LUCI_DEPENDS:=@TARGET_bcm53xx_generic_DEVICE_phicomm_k3
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-k3usb

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Shenzt <shenzt@gmail.com>

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
