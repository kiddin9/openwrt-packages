include $(TOPDIR)/rules.mk

PKG_NAME:=sms-tool
PKG_RELEASE:=23

PKG_SOURCE_URL:=https://github.com/obsy/sms_tool
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2022-03-21
PKG_SOURCE_VERSION:=null
PKG_MIRROR_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define Package/sms-tool
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=sms tool
  URL:=https://github.com/obsy/sms_tool
endef

define Package/sms-tool/description
	SMS Tool for 3G/4G modem
endef

define Package/sms-tool/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sms_tool $(1)/usr/bin/
endef

$(eval $(call BuildPackage,sms-tool))
