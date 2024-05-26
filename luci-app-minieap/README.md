OpenWrt/LEDE LuCI for minieap
===

**！锐捷服务名为中文时无法使用，请等待自定义配置文件功能启用！**

简介
---

本软件包是 minieap 的 LuCI 控制界面,

软件包文件结构:
```
/
├── etc/
│   ├── config/
│   │   └── minieap                                 // UCI 配置文件
│   └── init.d/
│       └── minieap                                 // init 脚本
└── usr/
    ├── lib/
    │   └── lua/
    │       └── luci/                               // LuCI 部分
    │           ├── controller/
    │           │   └── minieap.lua                 // LuCI 菜单配置
    │           ├── i18n/                           // LuCI 语言文件目录
    │           │   └── minieap.zh-cn.lmo
    │           └── model/
    │               └── cbi/
    │                   └── minieap/
    │                       ├── customfile.lua      // LuCI 自定义配置文件（未启用）
    │                       ├── general.lua         // LuCI 基本设置
    │                       └── log.lua             // LuCI 日志读取
    └── sbin/
        └── minieap-conver                          // uci->conf 可执行文件
```

依赖
---

软件包不显式依赖二进制文件 `minieap`.
可通过编译安装 [minieap-openwrt](https://github.com/BoringCat/minieap-openwrt) 获得.  
只有当文件存在时, 相应的功能才可被使用, 并显示相应的 LuCI 设置界面.  

 | 可执行文件 | 可选 | 功能            |
 | ---------- | ---- | --------------- |
 | `minieap`  | 否   | 进行802.11x验证 |

配置
---

软件包的配置文件路径: `/etc/config/minieap`  
此文件为 UCI 配置文件, 配置方式可参考 [OpenWrt Wiki][uci]  
执行时会将配置文件转换为minieap能识别的文件并置于 `/etc/minieap.conf.d/minieap.conf.utf8`， 创建软连接到 `/etc/minieap.conf`  
允许用户上传自定义配置文件，当存在多种文件编码的配置文件时，配置文件位于 `/etc/minieap.conf.d/`，根据用户选择的调整软连接

编译
---

从 OpenWrt/LEDE 的 [SDK][openwrt-sdk] 编译  

1. 下载路由器对应OpenWRT/LEDE版本的SDK
2. Clone 项目
```shell
git clone https://github.com/BoringCat/luci-app-minieap.git package/luci-app-minieap
```
3. 编译 po2lmo (如果有po2lmo可跳过)
```shell
git clone https://github.com/openwrt-dev/po2lmo.git
pushd po2lmo
make && sudo make install
popd
```
4. 进行编译
```shell
make defconfig
# 开始编译
make package/luci-app-minieap/compile V=s
```


[openwrt-sdk]: https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
[uci]: https://wiki.openwrt.org/doc/uci
