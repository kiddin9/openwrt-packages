# luci-app-nat6-helper


- 启用后根据 ipv6 的 wan6 接口状态，自动配置 nat6


Usage:

1. 检查软件包是否安装 `ip6tables kmod-ipt-nat6 kmod-ip6tables kmod-ip6tables-extra`，如若没有，请 ssh 运行 `opkg update && opkg install ip6tables kmod-ipt-nat6 kmod-ip6tables kmod-ip6tables-extra` 安装

2. 运行 ipv6nat.sh 脚本

- 方式一：Luci 界面点击 `执行 IPv6 初始化脚本` 一键执行（日志存放于 `/etc/ipv6nat.log`）
- 方式二：通过 SSH 手动执行

```
chmod +x /etc/ipv6nat.sh
bash /etc/ipv6nat.sh
```

3. 启用插件，保存并应用



# 参考链接：
1. [LEDE 下的 IPv6 NAT6](https://lixingcong.github.io/2017/04/24/ipv6-nat-lede/)
2. [OpenWrt 路由器如何让 lan 口主机获得 ipv6 网络访问？](https://www.zhihu.com/question/29667477)