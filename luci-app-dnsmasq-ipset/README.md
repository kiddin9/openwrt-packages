OpenWrt LuCI for ipset feature of dnsmasq-full
===

简介
---

本软件包是 dnsmasq-full IPSet 的 LuCI 控制界面,
方便用户实现根据域名路由。

![屏幕截图](https://github.com/lvqier/luci-app-dnsmasq-ipset/raw/master/images/screenshot.png)


编译
---

从 OpenWrt 的 [SDK][openwrt-sdk] 编译  
```bash
# 解压下载好的 SDK
tar xjf OpenWrt-SDK-ramips-for-linux-*.tar.bz2
cd OpenWrt-SDK-ramips-*
# Clone 项目
git clone https://github.com/lvqier/luci-app-dnsmasq-ipset.git package/luci-app-dnsmasq-ipset
# 选择要编译的包 LuCI -> 3. Applications
make menuconfig
# 开始编译
make package/luci-app-dnsmasq-ipset/compile V=99
```

 [openwrt-sdk]: https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
 [uci]: https://wiki.openwrt.org/doc/uci

