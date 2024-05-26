-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local fs  = require "nixio.fs" 
local sys = require "luci.sys"
local m, s, p

local play_on = (luci.sys.call("pidof lan-play > /dev/null"))==0

local state_msg = " "

if play_on then
    local now_server = io.popen("ps | grep lan-play | grep -v 'grep' | cut -d ' ' -f 14")
    local server_info = now_server:read("*all")
    now_server:close()
    state_msg="<span style=\"color:green;font-weight:bold\">" .. translate("Running") .. "</span>"  .. "<br /><br />Current Server Address    " .. server_info
else
    state_msg="<span style=\"color:red;font-weight:bold\">" .. translate("Stopped")  .. "</span>"
end

m = Map("switchlanplay", translate("Switch LAN Play"),
	translatef("Play local wireless Switch games over the Internet.") .. "<br /><br />" ..translate("Service status:") .. " - " .. state_msg)

s = m:section(TypedSection, "switch-lan-play", translate("Settings"))
s.addremove = false
s.anonymous = true

e = s:option(Flag, "enable", translate("Enabled"), translate("Enables or disables the switch-lan-play daemon."))
e.rmempty  = false
function e.write(self, section, value)
    if value == "1" then
        luci.sys.call("/etc/init.d/switchlanplay start >/dev/null")
    else
        luci.sys.call("/etc/init.d/switchlanplay stop >/dev/null")
    end
    luci.http.write("<script>location.href='./switchlanplay';</script>")
    return Flag.write(self, section, value)
end

ifname = s:option(ListValue, "ifname", translate("Interfaces"), translate("Specifies the interface to listen on."))

for k, v in ipairs(luci.sys.net.devices()) do
    if v ~= "lo" then
        ifname:value(v)
    end
end

relay_server_host = s:option(Value, "relay_server_host", translate("relay_server_host"), translate("Relay Host - IP address or domain name (Required)"))
    relay_server_host.datatype="host"
    relay_server_host.default="127.0.0.1"
    relay_server_host.rmempty="false"

relay_server_port = s:option(Value, "relay_server_port", translate("relay_server_port"),translate("Server Port (Required)"))
    relay_server_port.datatype="port"
    relay_server_port.default="11451"
    relay_server_port.rmempty="false"

p = s:option(Value, "pmtu", translate("PMTU"), translate("Some games require custom a PMTU. Set to 0 for default."))
    p.datatype="uinteger"
    p.default="0"

return m
