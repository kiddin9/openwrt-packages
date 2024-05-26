# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=rapidjson
PKG_RELEASE:=61

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Tencent/rapidjson.git
PKG_SOURCE_DATE:=2023-08-07
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=BSD 3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS+= \
	-DRAPIDJSON_BUILD_DOC=OFF \
	-DRAPIDJSON_BUILD_EXAMPLES=OFF \
	-DRAPIDJSON_BUILD_TESTS=OFF

define Package/rapidjson
  SECTION:=lib
  CATEGORY:=Libraries
  URL:=https://github.com/Tencent/rapidjson
  TITLE:=rapidjson JSON parser/generator for C++
  BUILDONLY:=1
endef

define Package/rapidjson/description
  A fast JSON parser/generator for C++ with both SAX/DOM style API
endef

$(eval $(call BuildPackage,rapidjson))
