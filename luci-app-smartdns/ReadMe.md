# luci-app-smartdns

此仓库为smartdns独立仓库，为单独编译使用, 在安装此界面前，需要先安装smartdns进程编译脚本。  
请先安装[openwrt-smartdns](https://github.com/pymumu/openwrt-smartdns)

仓库分为两个分支

1. master分支为openwrt 19.07之后版本使用，此版本基于javascript。
2. lede分支为lede分支使用， 此版本基于lua。

使用时，请使用配套的版本。

## 使用方式

如下命令操作路径为openwrt源代码所在目录。  

### 复制仓库中的文件到如下目录，并执行安装

```shell
feeds/luci/applications/luci-app-smartdns/
./scripts/feeds install luci -a
```

> lede请下载lede分支

### 执行openwrt配置, 选中luci-app-smartdns

* 选择路径：

LuCI > 3. Applications > luci-app-smartdns  

```shell
make menuconfig
```

* 编译模式：

1. 若编译独立软件包，选择编译模式为`M`
1. 若编译到固件中，选择编译模式为`*`

### 执行openwrt编译

仅编译软件包：

```shell
make package/feeds/luci/applications/luci-app-smartdns/compile
```

编译固件以及软件包。

```shell
make -j8
```

## 懒人脚本

可执行如下命令，一次性下载smartdns以及luci-app-smartdns。  
下列命令可采用复制粘贴的方式执行。

注意事项：

1. 执行下列命令时，需要确保当前路径为openwrt代码路径。
1. 确保执行过./scripts/feeds进行更新。
1. 若是LEDE，请更换`LUCIBRANCH`变量为

```shell
LUCIBRANCH="lede"
```

批量命令：

```shell
WORKINGDIR="`pwd`/feeds/packages/net/smartdns"
mkdir $WORKINGDIR -p
rm $WORKINGDIR/* -fr
wget https://github.com/pymumu/openwrt-smartdns/archive/master.zip -O $WORKINGDIR/master.zip
unzip $WORKINGDIR/master.zip -d $WORKINGDIR
mv $WORKINGDIR/openwrt-smartdns-master/* $WORKINGDIR/
rmdir $WORKINGDIR/openwrt-smartdns-master
rm $WORKINGDIR/master.zip

LUCIBRANCH="master" #更换此变量
WORKINGDIR="`pwd`/feeds/luci/applications/luci-app-smartdns"
mkdir $WORKINGDIR -p
rm $WORKINGDIR/* -fr
wget https://github.com/pymumu/luci-app-smartdns/archive/${LUCIBRANCH}.zip -O $WORKINGDIR/${LUCIBRANCH}.zip
unzip $WORKINGDIR/${LUCIBRANCH}.zip -d $WORKINGDIR
mv $WORKINGDIR/luci-app-smartdns-${LUCIBRANCH}/* $WORKINGDIR/
rmdir $WORKINGDIR/luci-app-smartdns-${LUCIBRANCH}
rm $WORKINGDIR/${LUCIBRANCH}.zip

./scripts/feeds install -a
make menuconfig

```

下载完成后，执行配置编译。

## 注意事项

如果安装完成后，未生效，可以重启设备，清空浏览器缓存，或用安全模式浏览。