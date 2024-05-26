-- Copyright (C) 2019 X-WRT <dev@x-wrt.com>

m = Map("macvlan", translate("Macvlan"))

s = m:section(TypedSection, "macvlan", translate("Macvlan Settings"))
s.addremove = true
s.anonymous = true
s.template = "cbi/tblsection"

o = s:option(Value, "ifname", translate("Interface"))
o.datatype = "string"
o.rmempty  = false

o = s:option(Value, "index", translate("Index"))
o.datatype = "and(uinteger,min(0),max(255))"
o.rmempty  = false

o = s:option(ListValue, "type", translate("Type"))
o:value("macvlan", translate("macvlan"))
o:value("ipvlan", translate("ipvlan"))

o = s:option(ListValue, "mode", translate("Mode"))
o:value("l2", translate("l2"))
o:value("l3", translate("l3"))

o = s:option(ListValue, "flag", translate("Flag"))
o:value("bridge", translate("bridge"))
o:value("private", translate("private"))
o:value("vepa", translate("vepa"))

return m
