local m, s, o
local uci = luci.model.uci.cursor()
local sys = require 'luci.sys'


m = Map("xunyou", translate("xunyou"), translate("迅游是一款小巧且功能强大的网游加速器，迅游所采用的第五代网游加速技术能更有效地为您解决网游卡机、掉线、延时高、登录难等问题。")
.. translatef("更多信息请"
.. "<a href=\"%s\" target=\"_blank\">"
.. "访问官网</a>", "https://www.xunyou.com/"))

m:section(SimpleSection).template  = "xunyou/status"

s=m:section(TypedSection, "xunyou", translate("Global settings"))
s.addremove=false
s.anonymous=true
s:option(Flag, "enabled", translate("Enable")).rmempty=false

o = s:option(Value, "interface", translate("Interface"), translate("Network interface for serving, usually LAN"))
o.template = "cbi/network_netlist"
o.nocreate = true
o.default = "lan"
o.datatype = "string"

return m