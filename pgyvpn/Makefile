include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/target.mk

ifeq ($(ARCH),arm)
  ifneq ($(findstring $(CPU_SUBTYPE), neon neon-vfpv4 vfpv3),)
	PKG_ARCH_PGYYPN:=arm_$(CPU_TYPE)_$(CPU_SUBTYPE)-$(LIBC)-unknown
  else ifneq ($(findstring $(CPU_TYPE), cortex-a9),)
	PKG_ARCH_PGYYPN:=arm_cortex-a9-$(LIBC)-unknown
  else
	PKG_ARCH_PGYYPN:=arm_cortex-a7-$(LIBC)-unknown
  endif
endif
ifeq ($(ARCH),aarch64)
  ifneq ($(findstring $(CPU_TYPE), cortex-a53 cortex-a72),)
	PKG_ARCH_PGYYPN:=aarch64_$(CPU_TYPE)-$(LIBC)-unknown
  else
	PKG_ARCH_PGYYPN:=aarch64_generic-$(LIBC)-unknown
  endif
endif
ifeq ($(ARCH),mips)
	PKG_ARCH_PGYYPN:=mips_24kc-$(LIBC)-unknown
endif
ifeq ($(ARCH),mipsel)
  ifneq ($(findstring $(CPU_TYPE), 24kec 74kc 1004kc),)
	PKG_ARCH_PGYYPN:=$(ARCH)_$(CPU_TYPE)-$(LIBC)-unknown
  else
	PKG_ARCH_PGYYPN:=mipsel_24kc-$(LIBC)-unknown
  endif
endif
ifeq ($(BOARD),x86)
  ifeq ($(ARCH),x86_64)
	PKG_ARCH_PGYYPN:=x86_64-$(LIBC)-unknown
  else
	PKG_ARCH_PGYYPN:=i386_pentium-mmx-$(LIBC)-unknown
  endif
endif

PKG_NAME:=pgyvpn
PKG_VERSION:=3.1.0
PKG_RELEASE:=12

PKG_SOURCE:=pgyvpnsvr
PKG_SOURCE_URL:=https://mirrors.oray.com/orayos/packages/$(PKG_NAME)/$(PKG_ARCH_PGYYPN)/$(PKG_VERSION)/bin
PKG_HASH:=skip

PKG_MAINTAINER:=Oray <developer@oray.com>

include $(INCLUDE_DIR)/package.mk

define Package/pgyvpn
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  DEPENDS:=@(arm||aarch64||mips||mipsel||i386||x86_64) \
	+iptables +libc +libopenssl +librt \
	+libpthread +libstdcpp +kmod-tun
  TITLE:=PuGongYing VPN, Fast networking
  URL:=https://pgy.oray.com/
endef

define Package/pgyvpn/description
  PuGongYing VPN is a product of Oray Company, support custom network, account security
  system, traffic monitoring, cloud application access, virtual serial port, etc.
endef

define Download/extra
  FILE:=pgyvpn_oraysl
  URL:=$(PKG_SOURCE_URL)
  HASH:=skip
endef
$(eval $(call Download,extra))

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	mv $(DL_DIR)/{pgyvpn_oraysl,pgyvpnsvr} $(PKG_BUILD_DIR)
	chmod +x $(PKG_BUILD_DIR)/{pgyvpn_oraysl,pgyvpnsvr}
endef

define Build/Compile
	true
endef

define Package/pgyvpn/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/share/pgyvpn

	$(CP) $(PKG_BUILD_DIR)/pgyvpn_oraysl $(1)/usr/sbin
	$(INSTALL_BIN) ./files/etc/init.d/* $(1)/etc/init.d
	$(INSTALL_CONF) ./files/etc/config/* $(1)/etc/config
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/* $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/usr/share/pgyvpn/* $(1)/usr/share/pgyvpn
endef

define Package/pgyvpn/preinst
	#!/bin/sh
	[ -z "$${IPKG_INSTROOT}" ] && {
		pidof pgyvpnsvr > /dev/null && \
			test -f $${PKG_ROOT}etc/init.d/pgyvpn && \
				/etc/init.d/pgyvpn stop; true
	}
	exit 0
endef

define Package/pgyvpn/postinst
	#!/bin/sh
	[ -z "$${IPKG_INSTROOT}" ] && {
		/etc/init.d/pgyvpn restart; true
	}
	exit 0
endef

$(eval $(call BuildPackage,pgyvpn))
