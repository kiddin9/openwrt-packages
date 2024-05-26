include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/target.mk

ifeq ($(ARCH),arm)
  ifneq ($(findstring $(CPU_SUBTYPE), neon neon-vfpv4 vfpv3),)
	PKG_ARCH_PHT:=arm_$(CPU_TYPE)_$(CPU_SUBTYPE)-$(LIBC)-unknown
  else ifneq ($(findstring $(CPU_TYPE), cortex-a9),)
	PKG_ARCH_PHT:=arm_cortex-a9-$(LIBC)-unknown
  else
	PKG_ARCH_PHT:=arm_cortex-a7-$(LIBC)-unknown
  endif
endif
ifeq ($(ARCH),aarch64)
  ifneq ($(findstring $(CPU_TYPE), cortex-a53 cortex-a72),)
	PKG_ARCH_PHT:=aarch64_$(CPU_TYPE)-$(LIBC)-unknown
  else
	PKG_ARCH_PHT:=aarch64_generic-$(LIBC)-unknown
  endif
endif
ifeq ($(ARCH),mips)
	PKG_ARCH_PHT:=mips_24kc-$(LIBC)-unknown
endif
ifeq ($(ARCH),mipsel)
  ifneq ($(findstring $(CPU_TYPE), 24kec 74kc 1004kc),)
	PKG_ARCH_PHT:=$(ARCH)_$(CPU_TYPE)-$(LIBC)-unknown
  else
	PKG_ARCH_PHT:=mipsel_24kc-$(LIBC)-unknown
  endif
endif
ifeq ($(BOARD),x86)
  ifeq ($(ARCH),x86_64)
	PKG_ARCH_PHT:=x86_64-$(LIBC)-unknown
  else ifeq ($(CPU_TYPE),pentium4)
	PKG_ARCH_PHT:=i386_pentium4-$(LIBC)-unknown
  else
	PKG_ARCH_PHT:=i386_pentium-mmx-$(LIBC)-unknown
  endif
endif

PKG_NAME:=phtunnel
PKG_VERSION:=1.0.0
PKG_RELEASE:=18

PKG_SOURCE:=phtunnel
PKG_SOURCE_URL:=https://mirrors.oray.com/orayos/packages/$(PKG_NAME)/$(PKG_ARCH_PHT)/$(PKG_VERSION)/bin
PKG_HASH:=skip

PKG_MAINTAINER:=Oray <developer@oray.com>

include $(INCLUDE_DIR)/package.mk

define Package/phtunnel
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=@(arm||aarch64||mips||mipsel||i386||x86_64) \
	+libc +libpthread +librt
  TITLE:=HSK Intranet penetration
  URL:=https://hsk.oray.com/
endef

define Package/phtunnel/description
  PHTunnel is the core component of HSK intranet penetration, which can easily implement high-performance
  reverse proxy applications, supports TCP, HTTP, HTTPS protocols, end-to-end TLS encrypted communication,
  black and white list anti-black verification, etc. Through PHTunnel, external network devices can easily
  penetrate various complex routes and firewalls to access devices on the internal network.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	mv $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)
	chmod +x $(PKG_BUILD_DIR)/$(PKG_SOURCE)
endef

define Build/Compile
	true
endef

define Package/phtunnel/conffiles
/etc/phtunnel.json
endef

define Package/phtunnel/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/usr/sbin

	$(CP) $(PKG_BUILD_DIR)/phtunnel $(1)/usr/sbin
	$(INSTALL_BIN) ./files/etc/init.d/* $(1)/etc/init.d
	$(INSTALL_CONF) ./files/etc/config/* $(1)/etc/config
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/* $(1)/etc/hotplug.d/iface
endef

define Package/phtunnel/preinst
	#!/bin/sh
	[ -z "$${IPKG_INSTROOT}" ] && {
		pidof phtunnel > /dev/null && \
			test -f $${PKG_ROOT}etc/init.d/phtunnel && \
				/etc/init.d/phtunnel stop; true
	}
	exit 0
endef

$(eval $(call BuildPackage,phtunnel))
