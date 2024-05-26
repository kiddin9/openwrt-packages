m = Map("natter", translate("Natter"), translate("Open Port under FullCone NAT (NAT 1)"))
s = m:section(TypedSection, "base")

s.addremove = false
s.anonymous = true

local function check_file(e)
	return luci.sys.exec('ls "%s" 2> /dev/null' % e) ~= "" and true or false
end

enable = s:option(Flag, "enable", translate("Enable"))
enable.default = 0

if check_file("/tmp/natter_nat_type") then
	natter_nat_type_tcp = luci.sys.exec ("grep TCP /tmp/natter_nat_type")
	natter_nat_type_udp = luci.sys.exec ("grep UDP /tmp/natter_nat_type")
	nat_check = s:option (Button, "nat_check", translate("Check NAT Status"), translate("") .. "<br><br>" .. natter_nat_type_tcp .. "<br><br>" .. natter_nat_type_udp)
else
	nat_check = s:option (Button, "nat_check", translate("Check NAT Status"))
end

nat_check.inputtitle = translate("Exec")
nat_check.write = function()
	luci.sys.call ("sh /usr/share/luci-app-natter/natcheck.sh > /tmp/natter_nat_type")
	luci.http.redirect(luci.dispatcher.build_url("admin", "network", "natter", "base"))
end

local_ip = s:option(Value, "local_ip", translate("Local IP Address"), translate("Natter Listening Address"))
local_ip.default = "0.0.0.0"
local_ip.placeholder = "0.0.0.0"
local_ip.datatype = "host"
local_ip.rmempty = false

log_path = s:option(Value, "log_path", translate("Log Path"), translate("Directory to save natter logs"))
log_path.default = "/tmp/natter"
log_path.placeholder = "/tmp/natter"
log_path.rmempty = false

keep_alive_server = s:option(Value, "keep_alive_server", translate("Keep Alive Server"), translate("Please ensure that the address can be connected by Natter"))
keep_alive_server.rmempty = false

tcp_stun_server = s:option(DynamicList, "tcp_stun_server", translate("TCP STUN Server"), translate("Please DO NOT handle the IP address/domain name/port of the TCP/UDP STUN server (3478) while running proxy"))
udp_stun_server = s:option(DynamicList, "udp_stun_server", translate("UDP STUN Server"))
udp_stun_server.rmempty = false

s = m:section(TypedSection, "ports", translate("Port Settings"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"
s.extedit = luci.dispatcher.build_url("admin", "network", "natter", "ports", "%s")
function s.create(...)
	local sid = TypedSection.create(...)
	if sid then
		luci.http.redirect(s.extedit % sid)
		return
	end
end

enable_port = s:option(Flag, "enable_port", translate("Enable"))
enable_port.default = 1
enable_port.width = "5%"

remarks = s:option(DummyValue, "remarks", translate("Remarks"))
remarks.width = "8%"

external_port_tcp = s:option(DummyValue, "external_port_tcp", translate("External TCP Port"))
external_port_tcp.width = "12%"

external_port_udp = s:option(DummyValue, "external_port_udp", translate("External UDP Port"))
external_port_udp.width = "12%"

enable_forward = s:option(Flag, "enable_forward", translate("Forward"))
enable_forward.default = 0

internal_ip = s:option(DummyValue, "internal_ip", translate("Internal IP Address"))
internal_ip.width = "12%"

internal_port = s:option(DummyValue, "internal_port", translate("Internal Port"))
internal_port.width = "12%"

return m
