#
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmmdvm
PKG_VERSION:=1.2.0
PKG_RELEASE:=5

# PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
# MAKE_PATH:=src
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Michael BD7MQB <bd7mqb@qq.com>

include $(INCLUDE_DIR)/package.mk

define Package/${PKG_NAME}
	SECTION:=net
	CATEGORY:=MMDVM
	TITLE:=Lua-C library for MMDVM
	DEPENDS:=+libstdcpp +liblua
endef

define Package/${PKG_NAME}/description
Lua-C library for MMDVM
endef

TARGET_CXXFLAGS = -O3 -Wall -std=c++0x -DOPENWRT=1
TARGET_LDFLAGS = -llua -lm -shared -L$(STAGING_DIR)/usr/lib

ifeq ($(ARCH),mips)
	TARGET_CFLAGS += -DWORDS_BIGENDIAN=1
	TARGET_CPPFLAGS += -DWORDS_BIGENDIAN=1
endif

MAKE_FLAGS +=\
		LD=$(TARGET_CXX) \
        CXXFLAGS="$(TARGET_CXXFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS)" \


# define Build/Compile
# 	$(call Build/Compile/Default,clean compile)
# endef

define Package/${PKG_NAME}/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mmdvm.so $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,${PKG_NAME}))