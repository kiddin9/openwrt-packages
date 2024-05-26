-- Copyright 2018 Ycarus (Yannick Chabanois) <ycarus@zugaina.org>
-- Licensed to the public under the Apache License 2.0.

m = Map("snmpd", translate("SNMPd"), translate("SNMPd settings interface (Beta)"))

s = m:section(TypedSection, "snmpd", translate("General"))
s.addremove = false

enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.rmempty  = false

network = s:option(Value, "network", translate("Networks"))
network.template = "cbi/network_netlist"
network.widget = "checkbox"
network.rmempty = true
network.cast = "string"
network.nocreate = true

s = m:section(TypedSection, "system", translate("System"))
s.addremove = false

sysLocation = s:option(Value, "sysLocation", translate("Location"))
sysContact = s:option(Value, "sysContact", translate("Contact"))
sysName = s:option(Value, "sysName", translate("Name"))
--sysServices = s:option(Value, "sysServices", translate("Services"))
--sysDescr = s:option(Value, "sysDescr", translate("Description"))
--sysObjectID = s:option(Value, "sysObjectID", translate("ObjectID"))

s = m:section(TypedSection, "com2sec", translate("com2sec security"))
s.addremove = true

secname = s:option(ListValue, "secname", translate("Server"))
secname.optional = false
secname:value("ro",translate("Read-only"))
secname:value("rw",translate("Read-write"))

source = s:option(Value, "source", translate("Source"))
source.datatype = "host"
source.optional = false
source.rmempty  = false

community = s:option(Value, "community", translate("Community"))
community.optional = false
community.rmempty = false

--s = m:section(TypedSection, "com2sec6", translate("com2sec6"))
--s.addremove = true

--secname = s:option(ListValue, "secname", translate("secname"))
--secname.optional = false
--secname:value("ro",translate("Read-only"))
--secname:value("rw",translate("Read-write"))

--source = s:option(Value, "source", translate("Source"))
--source.datatype = "host"
--source.optional = false
--source.rmempty  = false

--community = s:option(Value, "community", translate("Community"))
--community.optional = false
--community.rmempty  = false

s = m:section(TypedSection, "group", translate("Group"), translate("Groups help define access methods"))
s.addremove = true
s.anonymous = false

secname = s:option(ListValue, "secname", translate("secname"))
secname.optional = false
secname:value("ro",translate("Read-only"))
secname:value("rw",translate("Read-write"))

group = s:option(Value, "group", translate("Group"))
group.optional = false
group.rmempty = false

version = s:option(ListValue, "version", translate("version"))
version.optional = false
version:value("v1","v1")
version:value("v2c","v2c")
version:value("usm","usm")

s = m:section(TypedSection, "access", translate("Access"))
s.addremove = true
s.anonymous = false

group = s:option(Value, "group", translate("Group"))
group.optional = false
group.rmempty = false

version = s:option(ListValue, "version", translate("version"))
version.optional = false
version:value("any",translate("any"))
version:value("v1","v1")
version:value("v2c","v2c")
version:value("usm","usm")

context = s:option(ListValue, "context", translate("Context"))
context.optional = false
context:value("none","none")

level = s:option(ListValue, "level", translate("Level"))
level.optional = false
level:value("noauth",translate("noauth"))
level:value("auth",translate("auth"))

read = s:option(ListValue, "read", translate("Read"))
read.optional = false
read:value("all","all")
read:value("none","none")

write = s:option(ListValue, "write", translate("Write"))
write.optional = false
write:value("all","all")
write:value("none","none")

notify = s:option(ListValue, "notify", translate("Notify"))
notify.optional = false
notify:value("all","all")
notify:value("none","none")

--s = m:section(TypedSection, "engineid", translate("engineid"))
--s.addremove = false
--s.anonymous = true

--engineid = s:option(Value, "engineid", translate("engineid"))
--engineidtype = s:option(ListValue, "engineidtype", translate("engineidtype"))
--engineidtype:value("1",translate("IPv4"))
--engineidtype:value("2",translate("IPv6"))
--engineidtype:value("3",translate("MAC"))
--engineidnic = s:option(Value, "engineidnic", translate("engineidnic"))

s = m:section(TypedSection, "exec", translate("Exec"))
s.addremove = true
s.anonymous = true

miboid = s:option(Value, "miboid", translate("ObjectID"))
name = s:option(Value, "name", translate("Name"))
prog = s:option(Value, "prog", translate("Program"))
args = s:option(Value, "args", translate("Arguments"))

return m
