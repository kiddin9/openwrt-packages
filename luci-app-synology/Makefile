#
# Copyright (C) 2021-2099 ykxVK8yL5L <https://github.com/ykxVK8yL5L>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#


include $(TOPDIR)/rules.mk

LUCI_TITLE:=luci-app-Synology
LUCI_DEPENDS:=+kmod-tun +qemu-bridge-helper +qemu-x86_64-softmmu +kmod-kvm-intel +qemu-img +qemu-nbd


include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-synology/postinst
#!/bin.sh
chmod 755 /etc/init.d/synology
exit 0
endef


# call BuildPackage - OpenWrt buildroot signature
