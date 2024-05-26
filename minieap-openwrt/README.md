## 编译方法:

* 1.去官网下载一份sdk并解压

* 2.cd sdk

* 3.git clone https://github.com/AutoCONFIG/minieap-openwrt.git package/minieap-openwrt

* 4.make menuconfig

* 5.make package/minieap-openwrt/compile

## 仓库分支说明：
* main为默认分支，不带有任何的脚本，编译后的ipk仅包含minieap程序本体
* no_scripts_with_respawn 表示不带有执行脚本，集成启动项并加入守护进程参数
* no_scripts_without_respawn 表示不带有执行脚本，集成启动项但不加入守护进程参数 （如果不需要GUI配置界面且不需要守护进程，推荐此分支）
* default 带有执行脚本，适配GUI配置界面，集成启动项但不加入守护进程脚本（如果需要GUI配置界面需要切换至此分支）

## 分支切换方法：
* cd到clone仓库的更目录（例如：cd ~/minieap-openwrt)
* git branch -a (检查clone仓库的分支信息)
* git checkout 分支名称 （可以配合tab键自动填充）
* 完成！
