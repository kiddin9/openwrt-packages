local fs=require"nixio.fs"
local sys=require"luci.sys"

m=Map("homebridge", translate("HomeBridge"), translate("Configuration Homebridge"))
m:append(Template("homebridge/status"))
s=m:section(TypedSection,"homebridge", translate("Global Configuration"))
s.addremove=false
s.anonymous=true

o = s:option(Flag,"enabled",translate("Enable"))
o.rmempty = false
o.default = "1"

button = s:option(Button, "_button","安装")
button.inputtile=translate("exec")

function button.write(self, section, value)
	os.execute("/usr/share/homebridge/setup.sh &")
	local url = luci.dispatcher.build_url("/admin/services/homebridge/log/")
	luci.http.write("<script>location.href='"..url.."';</script>")
end

o = s:option(ListValue, "model", translate("Running Model"))
o:value("main", "Only Main")
o:value("independent", "Only Independent")
o:value("combine", "Main + Independent")
o.rmempty = false

o = s:option(Value, "interface", translate("mdns interface"))
o.datatype = "ip4addr"
o.rmempty = false
o.default = "192.168.1.1"

o = s:option(Value, "name", translate("Homebridge Name"))
o.rmempty = true
o.default = "homebridge"
o:depends("model", "main")
o:depends("model", "combine")

o = s:option(Value, "username", translate("Mac Address"))
o.rmempty = true
o.datatype = "macaddr"
o.default = "CC:22:3D:E3:CE:30"
o:depends("model", "main")
o:depends("model", "combine")

o = s:option(Value, "port", translate("Port"))
o.rmempty = true
o.datatype = "port"
o.default = "51826"
o:depends("model", "main")
o:depends("model", "combine")

o = s:option(Value, "pin", "Pin")
o.rmempty = true
o.datatype = "string"
o.default = "123-45-789"
o:depends("model", "main")
o:depends("model", "combine")

--local apply=luci.http.formvalue("cbi.apply")
--if apply then
--	luci.sys.call("export HOME='/root';/etc/init.d/homebridge restart")
--end

return m

