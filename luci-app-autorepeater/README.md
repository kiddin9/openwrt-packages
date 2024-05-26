AutoRepeater for OpenWrt
===

Helping to setup the router as a automatic repeater

Fun
---

- Configure via web GUI
- Auto connect to AP with specific MAC address or ssid name list
- Add AP switch On/Off button settings and, power LED blinking as failsafe mode indicates AP is OFF
- Use mminiupnpc mapping ports from routed IP
- Use macchanger to change device macaddr

Todo
---
- Rewrite to lua script.
- Add option to update station scanning peroidly
- Writes html log to http://<router.ip.address>/autorepeater.html
- Check network setup for G/mixed/B etc.

Idea's from
---
- kuthulu/Iron AutoAP Next Gen
- autowwan [autowwan]
- luci-app-autoap [autoap]
- wwanHotspot [wwanHotspot]

compile
---

 - Download [SDK][S], and it's depends:
   ```bash
   sudo apt-get install gawk libncurses5-dev libz-dev zlib1g-dev  git ccache
   ```
 
 - Download your own SDK

   ```bash
   # Untar ar71xx platform
   tar xjf OpenWrt-SDK-15.05-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
   cd OpenWrt-SDK-*
   # update feeds
   ./scripts/feeds update packages
   # Clone
   git clone https://github.com/peter-tank/openwrt-autorepeater.git package/openwrt-autorepeater
   # select this package
   make menuconfig
   
   # Compile and install po2lmo bin for build i18n language files
   pushd package/openwrt-autorepeater/tools/po2lmo
   make && sudo make install
   popd
   # I18n language files
   po2lmo ./package/openwrt-autorepeater/files/luci/i18n/autorepeater.zh-cn.po ./package/openwrt-autorepeater/files/luci/i18n/autorepeater.zh-cn.lmo
   
   # Compile
    make package/openwrt-autorepeater/compile V=99
   ```
installing
--- 
- Depends: iwinfo jshn jsonfilter awk


  [autowwan]: https://github.com/koniu/autowwan
  [autoap]: https://github.com/openwrt-1983/2015/tree/master/luci-app-autoap
  [wwanHotspot]: https://github.com/jordi-pujol/wwanHotspot/
  [S]: https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
