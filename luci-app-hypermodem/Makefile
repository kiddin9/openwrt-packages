#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Hyper Modem Server
LUCI_DEPENDS:=+luci-compat +kmod-usb-net  +kmod-usb-net-cdc-ether +kmod-usb-acm \
		+kmod-usb-net-qmi-wwan  +kmod-usb-net-rndis +kmod-usb-serial-qualcomm \
		+kmod-usb-net-sierrawireless +kmod-usb-ohci +kmod-usb-serial \
		+kmod-usb-serial-option +kmod-usb-wdm \
		+kmod-usb2 +kmod-usb3 \
		+kmod-usb-net-cdc-mbim \
		+usbutils \
		+luci-proto-qmi \
		+pciutils \
		+kmod-pcie_mhi \
		+quectel-CM-5G \
		+grep \

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
