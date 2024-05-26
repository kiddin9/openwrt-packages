local s = require "luci.sys"
local m, s, o
mp = Map("homeredirect", translate("Home Redirect - Port forwarding utility"))
mp.description = translate("HomeRedirect is a customized port forwarding utility for HomeLede. It supports TCP / UDP protocol, IPv4 and IPv6.")
mp:section(SimpleSection).template  = "homeredirect/index"

s = mp:section(TypedSection, "global")
s.anonymous = true

enabled = s:option(Flag, "enabled", translate("Master switch"))
enabled.default = 0
enabled.rmempty = false

s = mp:section(TypedSection, "redirect", translate("Redirect Configuration"))
s.addremove = true
s.anonymous = true
s.template = "cbi/tblsection"
s.sortable = true

enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.rmempty = false

name = s:option(Value, "name", translate("Name"))
name.optional = false
name.rmempty = false

proto = s:option(ListValue, "proto", translate("Transport Protocol"))
proto.default = "tcp4"
proto:value("tcp4", "TCP/IPv4")
proto:value("udp4", "UDP/IPv4")
proto:value("tcp6", "TCP/IPv6")
proto:value("udp6", "UDP/IPv6")

-- src_ip = s:option(Value, "src_ip", translate("Source IP"))
-- src_ip.datatype = "ipaddr"
-- src_ip.optional = false
-- src_ip.rmempty = false

src_dport = s:option(Value, "src_dport", translate("Source Port"))
src_dport.datatype = "port"
src_dport.optional = false
src_dport.rmempty = false

dest_ip = s:option(Value, "dest_ip", translate("Destination Address"))
dest_ip.datatype = "ipaddr"
dest_ip.optional = false
dest_ip.rmempty = false

dest_port = s:option(Value, "dest_port", translate("Destination Port"))
dest_port.datatype = "port"
dest_port.optional = false
dest_port.rmempty = false

o = s:option(DummyValue, "rs", translate("Status"))
o.default = "检测中..."

local apply=luci.http.formvalue("cbi.apply")
if apply then
    io.popen("/etc/init.d/homeredirect restart")
end

return mp
