-- Copyright 2019 X-WRT <dev@x-wrt.com>

m = Map("xwan", translate("Xwan"))

s = m:section(TypedSection, "xwan", translate("Xwan Settings"))
s.addremove = false
s.anonymous = true

e = s:option(Flag, "enabled", translate("Enable xwan"), translate("multiwan on single interface"))
e.default = e.disabled
e.rmempty = false

e = s:option(Value, "number", translate("Number of xwan"))
e.datatype = "and(uinteger,min(1),max(60))"
e.rmempty  = false

e = s:option(Flag, "balanced", translate("Auto balanced setup"))
e.default = e.disabled
e.rmempty = false

e = s:option(DynamicList, "track_ip", translate("Tracking hostname or IP address"), translate("This hostname or IP address will be pinged to determine if the link is up or down. Leave blank to assume interface is always online"))
e.datatype = 'host'
e.default = ""
e.placeholder = "gateway"

e = s:option(ListValue, 'family', translate("Internet Protocol"))
e.default = ''
e:value('', translate('IPv4 and IPv6'))
e:value('ipv4', translate('IPv4'))
e:value('ipv6', translate('IPv6'))

return m
