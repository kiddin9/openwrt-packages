m = Map("nat6-helper", "NAT6 配置助手") 
m.description = translate("IPv6 路由器做 NAT6，使得路由器下级可以使用 IPv6 协议访问网站。<br />参考链接：<br />https://github.com/Ausaci/luci-app-nat6-helper<br />https://lixingcong.github.io/2017/04/24/ipv6-nat-lede/")

m:section(SimpleSection).template  = "nat6-helper/nat6_status"

s = m:section(TypedSection, "nat6-helper")
s.addremove = false
s.anonymous = true

enabled = s:option(Flag, "enabled", translate("Enable"))
enabled.default = 0
enabled.rmempty = false

name = s:option(Value, "name", translate("Interface"))
name.rmempty = false
name.default = "wan6"
name.description = translate("填入 IPv6 接口名 (默认为 wan6 )，即可使 NAT6 随该接口状态自动开启或关闭")
run = s:option(Button, "run_button", translate("启动"))
run.inputstyle = "apply"
function run.write(self, section)
	io.popen("/etc/init.d/nat6-helper start")
end

stop = s:option(Button, "stop_button", translate("关闭"))
stop.inputstyle = "apply"
function stop.write(self, section)
	io.popen("/etc/init.d/nat6-helper stop")
end

init = s:option(Button, "init_button", translate("初始化"))
init.inputtitle = translate("执行 IPv6 初始化脚本")
init.inputstyle = "apply"
init.description = translate("执行 IPv6 初始化脚本 ( /etc/ipv6nat.sh )，仅需执行一次！")
function init.write(self, section)
	io.popen("bash /etc/ipv6nat.sh >> /etc/ipv6nat.log 2>&1")
end

return m
