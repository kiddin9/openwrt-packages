#
# Copyright (C) 2022 Wei Chen <weichen302@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.

include $(TOPDIR)/rules.mk

PKG_NAME:=xtables-wgobfs
PKG_VERSION:=0.4.1
PKG_RELEASE:=6

PKG_BUILD_DIR:=$(BUILD_DIR)/xt_wgobfs-$(PKG_VERSION)
PKG_SOURCE:=xt_wgobfs-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= https://github.com/infinet/xt_wgobfs/releases/download/v$(PKG_VERSION)/
PKG_HASH:=skip

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=iptables
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_MAINTAINER:=Wei Chen <weichen302@gmail.com>

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define Package/xtables-wgobfs
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Firewall
	TITLE:=iptables WireGuard obfuscation extension
	URL:=https://github.com/infinet/xt_wgobfs
	MAINTAINER:=Wei Chen <weichen302@gmail.com>
	DEPENDS:= +iptables +kmod-ipt-core +libxtables
endef

define Package/xtables-wgobfs/description
	An iptables extension for WireGuard obfuscation
endef

# uses GNU configure
CONFIGURE_ARGS+= \
	--with-kbuild="$(LINUX_DIR)" \
	--with-xtlibdir="/usr/lib/iptables" \

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		DEPMOD="/bin/true" \
		all
endef

define Build/Install
	mkdir -p $(PKG_INSTALL_DIR)/usr/lib/iptables/
	$(MAKE) -C $(PKG_BUILD_DIR) \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		DEPMOD="/bin/true" \
		install
endef

define Package/iptables-mod-wgobfs
	$(call Package/xtables-wgobfs)
	CATEGORY:=Network
	TITLE:=WireGuard obfuscation iptables extension
	DEPENDS:=+iptables +kmod-ipt-wgobfs
endef

define Package/iptables-mod-wgobfs/install
	$(INSTALL_DIR) $(1)/usr/lib/iptables
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/iptables/libxt_WGOBFS.so \
		$(1)/usr/lib/iptables/
endef

define KernelPackage/ipt-wgobfs
	SUBMENU:=Netfilter Extensions
	TITLE:=WireGuard obfuscation netfilter module
	DEPENDS:=+kmod-ipt-core
	FILES:=$(PKG_BUILD_DIR)/src/xt_WGOBFS.$(LINUX_KMOD_SUFFIX)
	AUTOLOAD:=$(call AutoProbe,xt_WGOBFS)
endef

$(eval $(call BuildPackage,iptables-mod-wgobfs))
$(eval $(call KernelPackage,ipt-wgobfs))
