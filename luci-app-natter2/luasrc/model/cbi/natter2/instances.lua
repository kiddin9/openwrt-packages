m = Map("natter2", translate("Instances Settings"),
translate("")
.. [[<a href="https://github.com/MikeWang000000/Natter/blob/master/docs/usage.md">]]
.. translate("Instructions")
.. [[</a>]])
m.redirect = luci.dispatcher.build_url("admin", "network", "natter2")

s = m:section(NamedSection, arg[1], "instances", "")
s.addremove = false
s.dynamic = false

local function check_binary(e)
	return luci.sys.exec('which "%s" 2> /dev/null' % e) ~= "" and true or false
end

enable_instance = s:option(Flag, "enable_instance", translate("Enable"))

local e = luci.sys.exec("cut -d '-' -f1 /proc/sys/kernel/random/uuid 2> /dev/null")
id = s:option(Value, "id", translate("ID"))
id.default = e

remark = s:option(Value, "remark", translate("Remark"))
remark.rmempty=false

protocol = s:option(ListValue, "protocol", translate("Protocol"))
protocol:value('tcp', translate("TCP"))
protocol:value('udp', translate("UDP"))
protocol.default = 'tcp'

enable_stun_server = s:option(Flag, "enable_stun_server", translate("Enable Stun Server"), translate("Using customized STUN server"))
stun_server = s:option(DynamicList, "stun_server", translate("STUN Server"))
stun_server.rmempty = true
stun_server:depends({enable_stun_server = "1"})

enable_keepalive_server = s:option(Flag, "enable_keepalive_server", translate("Enable Keepalive Server"), translate("Using customized Keepalive server"))
keepalive_server = s:option(Value, "keepalive_server", translate("Keepalive Server"))
keepalive_server.rmempty = true
keepalive_server:depends({enable_keepalive_server = "1"})

interval = s:option(Value, "interval", translate("Interval (Seconds)"), translate("The number of seconds between keepalive"))
interval.default = 15
interval.datatype = "uinteger"

enable_bonding = s:option(Flag, "enable_bonding", translate("Enable Bonding Options"), translate("Usually there is no need to enable binding"))
enable_bonding.rmempty = true
bonding_interface = s:option(Value, "bonding_interface", translate("Bonding Interface"))
bonding_interface.rmempty = true
bonding_interface.default = '0.0.0.0'
bonding_interface:depends({enable_bonding = "1"})

bonding_port = s:option(Value, "bonding_port", translate("Bonding Port"))
bonding_port.rmempty = true
bonding_port.default = '0'
bonding_port:depends({enable_bonding = "1"})

enable_forwarding = s:option(Flag, "enable_forwarding", translate("Enable Forwarding Options"), translate("Forwarding to internal devices"))

forwarding_method = s:option(ListValue, "forwarding_method", translate("Forwarding Method"),
translate("")
.. [[<a href="https://github.com/MikeWang000000/Natter/blob/master/docs/forward.md">]]
.. translate("Instructions for forwarding method")
.. [[</a>]])
forwarding_method:value('socket', translate("socket (Not Recommended)"))
if check_binary("iptables") then
	forwarding_method:value('iptables', translate("iptables (Recommended)"))
end
if check_binary("nftables") then
	forwarding_method:value('nftables', translate("nftables (Recommended)"))
end
if check_binary("socat") then
	forwarding_method:value('socat', translate("socat"))
end
if check_binary("gost") then
	forwarding_method:value('gost', translate("gost"))
end
forwarding_method.default = 'socket'
forwarding_method:depends({enable_forwarding = "1"})

target_address = s:option(Value, "target_address", translate("Target Address"))
target_address.datatype = "ipmask4"
luci.sys.net.ipv4_hints(
function(ip, name)
	target_address:value(ip, "%s (%s)" %{ ip, name })
end)
target_address:depends({enable_forwarding = "1"})

target_port = s:option(Value, "target_port", translate("Target Port"))
target_port.datatype = "port"
target_port:depends({enable_forwarding = "1"})

enable_forwarding_retry = s:option(Flag, "enable_forwarding_retry", translate("Enable Forwarding Retry"), translate("Retry until the target port is open"))
enable_forwarding_retry:depends({enable_forwarding = "1"})
enable_forwarding_retry.default = 1
enable_forwarding_retry.rmempty = false

enable_quit = s:option(Flag, "enable_quit", translate("Enable Quit"), translate("Exit immediately when the mapping address changes"))
enable_quit.default = "0"

delay = s:option(Value,"delay", translate("Start delay (Seconds)"), translate("Time to wait before starting this instance"))
delay.default = 0
delay.datatype = "uinteger"
delay.rmempty = false

log_level = s:option(ListValue, "log_level", translate("Log Level"))
log_level:value('normal', translate("Normal"))
log_level:value('verbose', translate("Verbose"))

enable_notify = s:option(Flag,"enable_notify", translate("Enable Notify Script"))
enable_notify.rmempty = false
notify_path = s:option(Value, "notify_path", translate("Notify Script Path"),
translate("")
.. [[<a href="https://github.com/MikeWang000000/Natter/blob/master/docs/script.md">]]
.. translate("Instructions for using the notification script")
.. [[</a>]])
notify_path.rmempty = true
notify_path.default = "/usr/share/luci-app-natter2/notify-example.sh"
notify_path:depends({enable_notify = "1"})

return m
