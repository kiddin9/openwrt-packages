# zPonds <admin@shinenet.cn>

include $(TOPDIR)/rules.mk

PKG_NAME:=nezha-agent
PKG_VERSION:=1
PKG_RELEASE:=7

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Nezha Agent is the client of the Nezha panel
	URL:=https://github.com/naiba/nezha/
endef


define Package/$(PKG_NAME)/description
Nezha Agent is the client of the Nezha panel
endef

# 禁止OpenWrt对二进制文件进行strip
STRIP:=true

ifeq ($(ARCH),i386)
	PKG_ARCH_NEZHA-AGENT:=386
endif

ifeq ($(ARCH),x86_64)
	PKG_ARCH_NEZHA-AGENT:=amd64
endif

ifeq ($(ARCH),mipsel)
	PKG_ARCH_NEZHA-AGENT:=mipsle
endif

ifeq ($(ARCH),mips)
	PKG_ARCH_NEZHA-AGENT:=mips
endif

ifeq ($(ARCH),arm)
	PKG_ARCH_NEZHA-AGENT:=arm
endif

ifeq ($(ARCH),arm64)
	PKG_ARCH_NEZHA-AGENT:=arm64
endif

ifeq ($(ARCH),aarch64)
	PKG_ARCH_NEZHA-AGENT:=arm64
endif


PKG_SOURCE:=nezha-agent_linux_$(PKG_ARCH_NEZHA-AGENT).zip

PKG_SOURCE_URL:=https://github.com/nezhahq/agent/releases/latest/download/

TAR_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_NAME)-TAR

PKG_HASH:=skip

define Build/Prepare
	mkdir -vp $(TAR_DIR)
	unzip $(DL_DIR)/$(PKG_SOURCE) -d $(TAR_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(TAR_DIR)/nezha-agent $(1)/usr/bin/$(PKG_NAME)
	chmod 755 $(1)/usr/bin/$(PKG_NAME)
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
