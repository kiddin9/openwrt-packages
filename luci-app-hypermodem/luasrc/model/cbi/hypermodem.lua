-- Copyright 2016 David Thornley <david.thornley@touchstargroup.com>
-- Licensed to the public under the Apache License 2.0.

mp = Map("hypermodem")
mp.title = translate("Hyper Modem Server")
mp.description = translate("Modem Server For OpenWrt")

s = mp:section(TypedSection, "service", translate("Base Setting"))
s.anonymous = true

enabled = s:option(Flag, "enabled", translate("Enable"))
enabled.default = 0
enabled.rmempty = false

ipv6 = s:option(Flag, "ipv6", translate("Enable IPv6"))
ipv6.default = 1
ipv6.rmempty = false

network_bridge = s:option(Flag, "network_bridge", translate("Enable Network bridge"))
network_bridge.description = translate("After checking, enable network interface bridge.")
network_bridge.default = 0
network_bridge.rmempty = false

device = s:option(Value, "device", translate("Modem device"))
device.rmempty = false

local device_suggestions = nixio.fs.glob("/dev/cdc-wdm*")

if device_suggestions then
	local node
	for node in device_suggestions do
		device:value(node)
	end
end

apn = s:option(Value, "apn", translate("APN"))
apn.default = ""
apn.rmempty = true
apn:value("", translate("Auto Choose"))
apn:value("cmnet", translate("China Mobile"))
apn:value("3gnet", translate("China Unicom"))
apn:value("ctnet", translate("China Telecom"))
apn:value("cbnet", translate("China Broadcast"))
apn:value("5gscuiot", translate("Skytone"))

auth = s:option(ListValue, "auth", translate("Authentication Type"))
auth.default = "none"
auth.rmempty = false
auth:value("none", translate("NONE"))
auth:value("both", translate("PAP/CHAP (both)"))
auth:value("pap", "PAP")
auth:value("chap", "CHAP")

username = s:option(Value, "username", translate("PAP/CHAP Username"))
username.rmempty = true
username:depends("auth", "both")
username:depends("auth", "pap")
username:depends("auth", "chap")

password = s:option(Value, "password", translate("PAP/CHAP Password"))
password.rmempty = true
password.password = true
password:depends("auth", "both")
password:depends("auth", "pap")
password:depends("auth", "chap")

return mp
