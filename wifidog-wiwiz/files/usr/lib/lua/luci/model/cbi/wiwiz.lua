m = Map("wiwiz", translate("Wiwiz")) 

portal = m:section(TypedSection, "wiwiz", "")

enabled = portal:option(Flag, "enabled", "启用");
enabled.optional = false 
enabled.rmempty = false

hotspotid = portal:option(Value, "hotspotid", "Hotspot ID", "注意区分大小写，不要有空格");
hotspotid.optional = false 
hotspotid.rmempty = false

--username = portal:option(Value, "username", "User Name", "Wiwiz平台用户请填写Wiwiz平台用户名；拼拼WiFi平台用户填写pinpinwifi"); 
--username.optional = false 
--username.rmempty = false

server = portal:option(Value, "server", "服务器地址与端口"); 
server.optional = false 
server.rmempty = false
server.default = "cp.wiwiz.com:80"

ver = portal:option(DummyValue, "ver", "Wiwiz插件版本", "<a href='http://www.wiwiz.com/pinpinwifi/wiwiz-ipk.htm' target='_blank'>使用说明</a>");

return m
