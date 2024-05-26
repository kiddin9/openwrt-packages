include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=rkp-ipid
PKG_RELEASE:=2

include $(INCLUDE_DIR)/package.mk

define KernelPackage/rkp-ipid
  SUBMENU:=Other modules
  TITLE:=RKP IPID
  FILES:=$(PKG_BUILD_DIR)/rkp-ipid.ko
  AUTOLOAD:=$(call AutoLoad, 99, rkp-ipid, 1)
endef

define KernelPackage/rkp-ipid/description
  Modify IDs of IP headers into numerically increasing order, for anti-detection of NAT.
endef

EXTRA_KCONFIG:= \
	CONFIG_RKP_IPID=m

EXTRA_CFLAGS:= \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=m,%,$(filter %=m,$(EXTRA_KCONFIG)))) \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=y,%,$(filter %=y,$(EXTRA_KCONFIG)))) \
	-DVERSION=$(PKG_RELEASE)

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	SUBDIRS="$(PKG_BUILD_DIR)" \
	EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
	$(EXTRA_KCONFIG)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		modules
endef

$(eval $(call KernelPackage, rkp-ipid))
