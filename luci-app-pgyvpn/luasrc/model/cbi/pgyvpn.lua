local sys = require("luci.sys")
local fs = require("nixio.fs")

m = Map("pgyvpn", translate("蒲公英智能组网"),
	translate("蒲公英 SD-WAN 为企业提供智能组网整体解决方案，全面覆盖互联网、专线、无线网络等" ..
		"常见接入方式，帮助用户快速部署并引入多线动态 BGP 网络出口宽带，大幅提升网络链接品质，" ..
		"组建虚拟局域网，打破地域限制，无需公网 IP,实现各地区设备，信息互联互通"))
pgyvpn = m:section(NamedSection, "base", "")
pgyvpn.addremove=false
pgyvpn.anonymous = false

user = pgyvpn:option(Value, "user", translate(""))
user.placeholder = "请输入SN码/贝锐账号"
user.rmempty = false -- 账号不为空
pwd = pgyvpn:option(Value, "pwd", translate(""))
pwd.placeholder = "请输入密码"
pwd.password = true -- 以* 号的形式显示密码
pwd.rmempty = false -- 密码不为空

local apply = luci.http.formvalue("cbi.apply")
if apply then
	os.execute("/etc/init.d/pgyvpn restart  > /dev/null");
end

return m
