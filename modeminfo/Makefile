include $(TOPDIR)/rules.mk

PKG_NAME:=modeminfo
PKG_VERSION:=0.4.1
PKG_RELEASE:=60
PKG_MAINTAINER:=Konstantine Shevlakov <shevlakov@132lan.ru>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)/Default
  PKGARCH:=all
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Telephony
endef

define Package/$(PKG_NAME)
  $(call Package/$(PKG_NAME)/Default)
  DEPENDS:=+comgt
  TITLE:=Signal information for 3G/LTE dongle
endef

define Package/$(PKG_NAME)-qmi
  $(call Package/$(PKG_NAME)/Default)
  DEPENDS:=+modeminfo +qmi-utils
  TITLE:=QMI addon for modeminfo
endef

define Package/$(PKG_NAME)-telegram
  $(call Package/$(PKG_NAME)/Default)
  DEPENDS:=+modeminfo +telegrambot
  TITLE:= Plugin for telegrambot
endef

define Package/$(PKG_NAME)/description
	Signal information for 3G/LTE dongle
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/modeminfo
endef

define SerialPlugin
  define Package/$(PKG_NAME)-serial-$(1)
    $$(call Package/$(PKG_NAME)/Default)
    DEPENDS:= +modeminfo $(2) +atinout
    TITLE:=$(3) serial addon for modeminfo
  endef
  define Package/$(PKG_NAME)-serial-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/share/$(PKG_NAME)/scripts
	$(CP) ./root/usr/share/$(PKG_NAME)/scripts/$(4)*  $$(1)/usr/share/$(PKG_NAME)/scripts
  endef
  $$(eval $$(call BuildPackage,$(PKG_NAME)-serial-$(1)))
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef


define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/modeminfo
	$(INSTALL_DIR) $(1)/usr/share/modeminfo/scripts
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./root/usr/bin/* $(1)/usr/bin
	$(CP) ./root/usr/share/modeminfo/modeminfo $(1)/usr/share/modeminfo/
	$(CP) ./root/usr/share/modeminfo/mccmnc.dat  $(1)/usr/share/modeminfo/
	$(CP) ./root/usr/share/modeminfo/scripts/*.gcom  $(1)/usr/share/modeminfo/scripts/
	$(CP) ./root/usr/share/modeminfo/scripts/ch_to_band  $(1)/usr/share/modeminfo/scripts/
	$(CP) ./root/usr/share/modeminfo/scripts/family.at  $(1)/usr/share/modeminfo/scripts/
	$(CP) ./root/usr/share/modeminfo/scripts/modeminfo  $(1)/usr/share/modeminfo/scripts/
	$(CP) ./root/usr/share/modeminfo/scripts/GENERIC* $(1)/usr/share/modeminfo/scripts/
	$(CP) ./root/etc/config/* $(1)/etc/config
endef

define Package/$(PKG_NAME)-qmi/install
	$(INSTALL_DIR) $(1)/usr/share/modeminfo/scripts
	$(CP) ./root/usr/share/modeminfo-qmi/* $(1)/usr/share/modeminfo/scripts
endef

define Package/$(PKG_NAME)-telegram/install
	$(INSTALL_DIR) $(1)/usr/lib/telegrambot/plugins
	$(CP) ./root/usr/lib/telegrambot/plugins/* $(1)/usr/lib/telegrambot/plugins
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call SerialPlugin,simcom-a7xxx,+kmod-usb-serial-option +kmod-usb-acm,SIMCOM A7600/A7906,A7XXX))
$(eval $(call SerialPlugin,simcom,+kmod-usb-serial-option,SIMCOM SIM7600/SIM7906/SIM7912,SIMCOM))
$(eval $(call SerialPlugin,huawei,+kmod-usb-serial-option,HUAWEI,HUAWEI))
$(eval $(call SerialPlugin,quectel,+kmod-usb-serial-option,QUECTEL,QUECTEL))
$(eval $(call SerialPlugin,fibocom,+kmod-usb-serial-option,FIBOCOM NL668/678,FIBOCOM))
$(eval $(call SerialPlugin,telit,+kmod-usb-serial-option,TELIT LN940/T77W678/HP4220,QUALCOMM))
$(eval $(call SerialPlugin,xmm,+kmod-usb-acm,FIBOCOM L850/L860 Intel XMM chips,INTEL))
$(eval $(call SerialPlugin,mikrotik,+kmod-usb-acm,MikroTik R11e-LTE/R11e-LTE6,MIKROTIK))
$(eval $(call SerialPlugin,meig,+kmod-usb-serial-option,MEIGLink SLM750-R2/SLM820/SLM828,MEIGLINK))
$(eval $(call SerialPlugin,sierra,+kmod-usb-serial-qualcomm,Sierra Wireless EM7455,SIERRA))
$(eval $(call SerialPlugin,styx,+kmod-usb-serial-option,STYX MG8224,STYX))
$(eval $(call SerialPlugin,dell,+kmod-usb-serial-option,Dell DW5821e,DELL))
$(eval $(call SerialPlugin,gosun,+kmod-usb-serial-option,Gosuncnwelink GM510,GOSUN))
$(eval $(call SerialPlugin,tw,+kmod-usb-serial-option,ThinkWill ML7820+,THINKWILL))
$(eval $(call SerialPlugin,yuge,+kmod-usb-serial-option,Yuge CLM920,YUGE))
$(eval $(call SerialPlugin,zte,+kmod-usb-serial-option,ZTE MF823/MF823D,ZTE))
$(eval $(call SerialPlugin,fm350,+kmod-usb-acm,FIBOCOM FM350,FM350))
$(eval $(call BuildPackage,$(PKG_NAME)-qmi))
$(eval $(call BuildPackage,$(PKG_NAME)-telegram))
