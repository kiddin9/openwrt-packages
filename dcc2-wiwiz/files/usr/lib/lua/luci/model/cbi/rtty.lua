m = Map("rtty", translate("Wiwiz")) 

rtty = m:section(TypedSection, "rtty", "")

enabled = rtty:option(Flag, "enabled", "启用");
enabled.optional = false 
enabled.rmempty = false

id = rtty:option(Value, "id", "设备ID", "若为空则使用设备的mac地址作为设备ID");
id.optional = true 
id.rmempty = false
id.addremove = false

token = rtty:option(Value, "token", "用户Token");
token.optional = false 
token.rmempty = false

description = rtty:option(Value, "description", "备注"); 
description.optional = true 
description.rmempty = false
description.addremove = false

host = rtty:option(Value, "host", "服务器地址"); 
host.optional = false 
host.rmempty = false

port = rtty:option(Value, "port", "服务器端口"); 
port.optional = false 
port.rmempty = false
port.default = "5912"

return m
