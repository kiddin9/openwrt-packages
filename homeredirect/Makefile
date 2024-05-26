#
# Copyright (c) 2020 xiaoqingfeng (xiaoqingfengatgm@gmail.com)
# Feed site - https://github.com/xiaoqingfengATGH/feeds-xiaoqingfeng
# This is free software, licensed under the GNU General Public License v3.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=HomeRedirect
PKG_VERSION:=1.4
PKG_RELEASE:=5
PKG_DATE:=20210226

PKG_MAINTAINER:=xiaoqingfeng <xiaoqingfengatgm@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Port forwarding utility for HomeLede.
  DEPENDS:=+bash +coreutils-nohup +socat
  PKGARCH:=all
  URL:=https://github.com/xiaoqingfengATGH/feeds-xiaoqingfeng
endef

define Package/$(PKG_NAME)/config
help
	$(PKG_NAME)
	Version: $(PKG_VERSION)-$(PKG_RELEASE)
	Port forwarding utility for HomeLede. Support TCP/UDP ipv4 & ipv6.
endef

define Package/$(PKG_NAME)/description
Port forwarding utility for HomeLede. Support TCP/UDP ipv4 & ipv6.
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/homeredirect
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/homeredirect
	$(INSTALL_BIN) files/etc/init.d/homeredirect $(1)/etc/init.d
	$(INSTALL_CONF) files/etc/config/homeredirect $(1)/etc/config
	$(INSTALL_DATA) files/etc/homeredirect/firewall.include $(1)/etc/homeredirect/
	$(INSTALL_DATA) files/etc/homeredirect/script.sh $(1)/etc/homeredirect/
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
/etc/init.d/homeredirect stop
uci -q batch <<-EOF >/dev/null
	delete ucitrack.@homeredirect[-1]
	commit ucitrack
EOF
uci -q batch <<-EOF >/dev/null
	delete firewall.homeredirect
EOF
exit 0
endef

define Build/Configure
endef

define Build/Prepare
endef

define Build/Compile
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
