-- Copyright (C) 2014-2018 Jian Chang <aa65535@live.com>
-- Copyright (C) 2020-2023 honwen <https://github.com/honwen>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocks = "shadowsocks"
local uci = luci.model.uci.cursor()
local servers = {}

local function has_bin(name)
	return luci.sys.call("command -v %s >/dev/null" %{name}) == 0
end

local function has_udp_relay()
	return luci.sys.call("lsmod | grep -q TPROXY && command -v ip >/dev/null") == 0
end

local function support_fast_open()
	local bit = luci.sys.exec("cat /proc/sys/net/ipv4/tcp_fastopen 2>/dev/null"):trim()
	return bit == "1" or bit == "3"
end

local has_ss = has_bin("sslocal")

if not has_ss then
	return Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"),
		translate("General Settings")}, '<b style="color:red">shadowsocks-rust binary file not found.</b>')
end

local function is_running(name)
	return luci.sys.call("pgrep -f '%s' >/dev/null" %{name}) == 0
end

local function get_status(name)
	return is_running(name) and translate("RUNNING") or translate("NOT RUNNING")
end

uci:foreach(shadowsocks, "servers", function(s)
	if s.server and s.server_port then
		servers[#servers+1] = {name = s[".name"], alias = s.alias or "%s:%s" %{s.server, s.server_port}}
	end
end)

m = Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("General Settings")})
m.template = "shadowsocks/general"

-- [[ Running Status ]]--
s = m:section(TypedSection, "general", translate("Running Status"))
s.anonymous = true

o = s:option(DummyValue, "_redir_status", translate("Transparent Proxy"))
o.value = "<span id=\"_redir_status\">%s</span>" %{get_status("/var/run/ss-redir")}
o.rawhtml = true

o = s:option(DummyValue, "http_status", translate("HTTP Proxy"))
o.value = "<span id=\"_http_status\">%s</span>" %{get_status("/var/run/ss-local-http")}
o.rawhtml = true

o = s:option(DummyValue, "socks_status", translate("SOCKS5 Proxy"))
o.value = "<span id=\"_socks_status\">%s</span>" %{get_status("/var/run/ss-local-socks")}
o.rawhtml = true

o = s:option(DummyValue, "_tunnel_status", translate("Port Forward"))
o.value = "<span id=\"_tunnel_status\">%s</span>" %{get_status("/var/run/ss-tunnel")}
o.rawhtml = true

s = m:section(TypedSection, "general", translate("Global Settings"))
s.anonymous = true

o = s:option(Value, "startup_delay", translate("Startup Delay"))
o:value(0, translate("Not enabled"))
for _, v in ipairs({3, 5, 10, 15, 25, 40}) do
	o:value(v, translatef("%u seconds", v))
end
o.datatype = "uinteger"
o.default = 0
o.rmempty = false

o = s:option(Value, "udp_timeout", translate("Timeout for UDP Associations"))
for _, v in ipairs({10, 30, 60, 120, 180, 300, 600, 1800}) do
	o:value(v, translatef("%u seconds", v))
end
o.default = 300
o.rmempty = false

o = s:option(Value, "udp_max_associations", translate("Maximum UDP Associations"))
o:value(0, translate("Unlimited"))
for _, v in ipairs({64, 256, 1024, 5120, 8192, 32768}) do
	o:value(v)
end
o.default = 512
o.rmempty = false

o = s:option(Flag, "no_dns_injection", translate("Disable DNS Auto-Injection"))
o.rmempty = false

-- [[ Transparent Proxy ]]--
s = m:section(TypedSection, "transparent_proxy", translate("Transparent Proxy"))
s.anonymous = true

o = s:option(Flag, "no_delay", translate("TCP no-delay"))
o.rmempty = false
if support_fast_open() then
  o = s:option(Flag, "fast_open", translate("TCP Fast Open"))
  o.rmempty = false
end

o = s:option(DynamicList, "main_server", translate("Main Server"))
o:value("nil", translate("Disable"))
for _, s in ipairs(servers) do o:value(s.name, s.alias) end
o.default = "nil"
o.rmempty = false

o = s:option(ListValue, "udp_relay_server", translate("UDP-Relay Server"))
if has_udp_relay() then
	o:value("nil", translate("Disable"))
	o:value("same", translate("Same as Main Server"))
	for _, s in ipairs(servers) do o:value(s.name, s.alias) end
else
	o:value("nil", translate("Unusable - Missing iptables-mod-tproxy or ip"))
end
o.default = "nil"
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1234
o.rmempty = false

o = s:option(Flag, "no_healthcheck", translate("Disable HealthCheck"))
o.rmempty = false

-- [[ HTTP Proxy ]]--
s = m:section(TypedSection, "http_proxy", translate("HTTP Proxy"))
s.anonymous = true

o = s:option(Flag, "no_delay", translate("TCP no-delay"))
o.rmempty = false
if support_fast_open() then
  o = s:option(Flag, "fast_open", translate("TCP Fast Open"))
  o.rmempty = false
end

o = s:option(DynamicList, "server", translate("Server"))
o:value("nil", translate("Disable"))
for _, s in ipairs(servers) do o:value(s.name, s.alias) end
o.default = "nil"
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1080
o.rmempty = false

-- [[ SOCKS5 Proxy ]]--
s = m:section(TypedSection, "socks_proxy", translate("SOCKS5 Proxy"))
s.anonymous = true

o = s:option(Flag, "no_delay", translate("TCP no-delay"))
o.rmempty = false
if support_fast_open() then
  o = s:option(Flag, "fast_open", translate("TCP Fast Open"))
  o.rmempty = false
end

o = s:option(DynamicList, "server", translate("Server"))
o:value("nil", translate("Disable"))
for _, s in ipairs(servers) do o:value(s.name, s.alias) end
o.default = "nil"
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1080
o.rmempty = false

-- [[ Port Forward ]]--
s = m:section(TypedSection, "port_forward", translate("Port Forward"))
s.anonymous = true

o = s:option(Flag, "no_delay", translate("TCP no-delay"))
o.rmempty = false
if support_fast_open() then
  o = s:option(Flag, "fast_open", translate("TCP Fast Open"))
  o.rmempty = false
end

o = s:option(DynamicList, "server", translate("Server"))
o:value("nil", translate("Disable"))
for _, s in ipairs(servers) do o:value(s.name, s.alias) end
o.default = "nil"
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 5300
o.rmempty = false

o = s:option(Value, "destination", translate("Destination"))
o.default = "8.8.4.4:53"
o.rmempty = false

return m
