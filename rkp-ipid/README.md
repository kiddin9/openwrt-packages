汪汪汪，这里是一个修改 IPID 的小模块，或许可以用来防止学校检测到使用代理（接路由器）。不过，我到现在为止，还没有确认哪个学校使用的是这种方法，更多的是使用时间戳和 UA。

这个模块不是根据源地址和目标地址来决定是否修改数据包的，而是根据 mark。它会修改所有第 5 位被置为 1 的数据包的 IPID 为顺序递增，第 5 位和第 6 位都被置为 1 的数据包为随机数，其它数据包不会改动。所以你需要另外写防火墙规则，设置你想要修改的数据包的 mark 为恰当的值。

例如，要设置所有发出的数据包的 IPID 为递增，用下面的命令：

```bash
iptables -t mangle -N IPID_MOD
iptables -t mangle -A FORWARD -j IPID_MOD
iptables -t mangle -A OUTPUT -j IPID_MOD
iptables -t mangle -A IPID_MOD -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A IPID_MOD -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A IPID_MOD -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A IPID_MOD -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A IPID_MOD -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A IPID_MOD -d 255.0.0.0/8 -j RETURN
iptables -t mangle -A IPID_MOD -j MARK --set-xmark 0x10/0x10
```

如果你不愿意使用这两个 mark 点来判断，可以临时地使用参数重新装载模块：

```bash
# 卸载模块
rmmod rkp-ipid
# 使用默认参数加载模块，相当于 insmod rkp-ipid mark_capture=0x10 mark_ramdom=0x20
insmod rkp-ipid
# 使用自定义参数加载模块
insmod rkp-ipid mark_capture=0x40 mark_ramdom=0x80
```

也可以修改 `/etc/modules.d/99-rkp-ipid` 来修改开机启动时加载模块的参数。例如，可以将它修改为：

```
rkp-ipid mark_capture=0x40 mark_ramdom=0x80
```

另外，不要在 luci 中启用 flow offloading（流量分载，即 nat 加速），否则这个模块会失效。

还有就是，随机 ID 很吃性能，慎用。

这个模块算是我随便写的，作为 xmurp-ua 的一个衍生物。所以，文档我就不写太多了，一些通用的信息直接去看 xmurp-ua。
