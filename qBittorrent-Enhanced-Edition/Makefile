include $(TOPDIR)/rules.mk

PKG_NAME:=qBittorrent-Enhanced-Edition
PKG_VERSION:=4.6.3.10
PKG_RELEASE:=63

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/c0re100/qBittorrent-Enhanced-Edition/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-release-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:qbittorrent:qbittorrent

PKG_BUILD_DEPENDS:=qt6tools/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/qbittorrent-enhanced-edition
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=bittorrent client programmed in C++ / Qt
  URL:=https://github.com/c0re100/qBittorrent-Enhanced-Edition
  DEPENDS:=+libtorrent-rasterbar +libQt6Core +libQt6Network +libQt6Sql \
    +libQt6Xml +qt6-plugin-libqopensslbackend +qt6-plugin-libqsqlite
  PROVIDES:=qbittorrent
endef

define Package/qbittorrent-enhanced-edition/description
  qBittorrent is a bittorrent client programmed in C++ / Qt that uses
  libtorrent (sometimes called libtorrent-rasterbar) by Arvid Norberg.
  It aims to be a good alternative to all other bittorrent clients out
  there. qBittorrent is fast, stable and provides unicode support as
  well as many features.
endef

define Package/qbittorrent-enhanced-edition/conffiles
/etc/config/qbittorrent
/etc/qBittorrent/
endef

CMAKE_OPTIONS+= \
	-DGUI=OFF \
	-DQT6=ON \
	-DSTACKTRACE=OFF \
	-DWEBUI=ON \
	-DQT_ADDITIONAL_PACKAGES_PREFIX_PATH=$(STAGING_DIR_HOSTPKG)

define Package/qbittorrent-enhanced-edition/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qbittorrent-nox $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/qbittorrent.config $(1)/etc/config/qbittorrent
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/qbittorrent.init $(1)/etc/init.d/qbittorrent
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(CURDIR)/files/qbittorrent.uci $(1)/etc/uci-defaults/90-qbittorrent-uci-migration
endef

$(eval $(call BuildPackage,qbittorrent-enhanced-edition))
