luci-wifidog
===========

wifidog的luci管理界面，基于lede的可编译package


---
## 安装方法

克隆本项目到本地
将目录名称由 luci-wifidog 改名成 luci-app-wifidog
复制 luci-app-wifidog 目录到本地lede的目录树中，目录结构如下：lede/package/feeds/luci/luci-app-wifidog

注意：里面的脚本要注意文件格式及可执行属性，到了linux系统里要用chmod及dos2unix命令作适当调整  
/etc/init.d/wifidog  
/etc/uci-defaults/luci-wifidog


## 编译

编译是sdk环境中要有wifidog选项：
1. 执行make menuconfig，在LuCI -》3. Applications-》luci-app-wifidog 找到该包，勾选上。
2. 编译整个sdk

---
## 使用方法 for wifidog v1.3.0

首先需要安装wifidog
```bash
opkg update
opkg install wifidog
```


拷贝各文件到相应文件夹中替换原文件, __注意：__  
/etc/uci-defaults 
/etc/init.d/wifidog 替换源文件， 并使用 chmod +x wifidog 增加可执行权限.

在LUCI中就可以看见出现wifidog配置菜单了，填写相应参数，保存+应用;  
LUCI -> System -> Startup  找到Wiifidog 启用之，重启路由器即可自动执行脚本运行wifidog，并生效配置。
