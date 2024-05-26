# LuCI Interface for ChinaDNS Next Generation for OpenWrt

## 简介

此仓库克隆自：https://github.com/pexcn/openwrt-chinadns-ng/tree/luci

本项目为 [openwrt-chinadns-ng](https://github.com/pexcn/openwrt-chinadns-ng) 提供 LuCI 接口。

## 编译

从 OpenWrt 的 [SDK](https://openwrt.org/docs/guide-developer/obtain.firmware.sdk) 编译
```bash
cd openwrt-sdk

# 获取源码
git clone https://github.com/izilzty/luci-app-chinadns-ng.git package/luci-app-chinadns-ng

# 选中 LuCI -> Applications -> luci-app-chinadns-ng
make menuconfig

# 编译 luci-app-chinadns-ng
make package/luci-app-chinadns-ng/{clean,compile} V=s
```

## 配置应用后自动重启

如果想要在配置应用后自动重启 ChinaDNS-NG ，则需要添加一个触发器用来重启服务，否在在配置应用后需要手动重启 ChinaDNS-NG 才可以加载新配置。
您可以选择其中一种：

- 编译并安装这个修改好的 ChinaDNS-NG 包： https://github.com/izilzty/openwrt-chinadns-ng.git 。
- 手动编辑已经安装好的 ChinaDNS-NG 文件：
打开 `/etc/init.d/chinadns-ng`，将下面的代码添加到文件最后，完成后保存文件并手动重启一下 ChinaDNS-NG 的服务或者重启系统。

  ```
  service_triggers() {
          procd_add_reload_trigger "chinadns-ng"
  }
  ```

## 鸣谢

- [@zfl9/chinadns-ng](https://github.com/zfl9/chinadns-ng)
- [@aa65535/openwrt-chinadns](https://github.com/aa65535/openwrt-chinadns)
