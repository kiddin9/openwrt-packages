<img src="./preview/light.png"/> 

# luci-theme-design

**luci-theme-design**基于[luci-theme-neobird](https://github.com/thinktip/luci-theme-neobird)二次开发, 适用于lede For Lean's OpenWRT Only [lede](https://github.com/coolsnowwolf/lede)

- 修复安装package提示信息背景泛白
- 优化菜单缩放
- 优化显示网口down状态显示图标
- 优化logo显示
- 新增各设备状态图标显示
- 更换logo显示为字体"OpenWrt"，支持以主机名显示logo
- 修复部分插件显示bug
- 修复vssr状态bar
- 修复诸多bug
- 修复兼容部分插件样式
- 修复aliyundrive-webdav样式
- 修复vssr在iOS/iPadOS WebApp模式下显示异常
- 修复openclash插件在iOS/iPadOS WebApp 模式下env(safe-area-inset-bottom) = 0
- 优化菜单hover action状态分辨
- 支持luci-app-wizard向导菜单
- Update header box-shadow style
- Update uci-change overflow
- Fix nlbw component
- Added QSDK/QWRT wizard and iStore menu icon fonts

## 主要特点

- 针对移动端优化，特别适合手机端做为webapp使用
- 修改和优化了很多插件显示，完善的icon图标，尽量视觉统一
- 简洁的登录界面，底部导航栏，类App的沉浸式体验；
- 适配深色模式，适配系统自动切换；

## 体验Webapp方法

- 在移动端(iOS/iPadOS)浏览器打开管理界面，添加到主屏幕即可。
- 想要实现完全的沉浸式（无浏览器导航、无地址栏等）体验，需要使用SSL证书，请自行申请域名、证书、安装并启用。
- 如果不使用SSL证书，基于安全原因，iOS/iPadOS 在打开新的页面后，将会显示浏览器顶部菜单栏。

## PS

- 资源接口icon未完善，如果有能力画图的欢迎pr，但请确保跟现有icon颜色风格一致
- 有bug欢迎提issue
- 主题个人配色可能会不符合大众胃口，欢迎提配色建议

## 自行编译

```
git clone https://github.com/gngpp/luci-theme-design.git  package/luci-theme-design
make menuconfig # choose LUCI->Theme->Luci-theme-design  
make V=s
```

## 预览(ps: 下面PC端普通字体为苹果浏览器字体，只有移动端是正常显示的)

<details> <summary>iOS</summary>
<img src="./preview/webapp_home.PNG"/>
<img src="./preview/webapp_vssr.PNG"/>
</details>

<details> <summary>iPadOS</summary>
<img src="./preview/IMG_0328.PNG"/>
<img src="./preview/IMG_0329.PNG"/>
</details>

<img src="./preview/login.png"/>
<img src="./preview/home.png"/>
<img src="./preview/home1.png"/>
<img src="./preview/wifi.png"/>
<img src="./preview/iface.png"/>

