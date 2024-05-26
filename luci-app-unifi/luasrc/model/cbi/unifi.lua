--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local unifi_model = require "luci.model.unifi"
local m, s, o

m = taskd.docker_map("unifi", "unifi", "/usr/libexec/istorec/unifi.sh",
	translate("UnifiController"),
	translate("UnifiController ubnt.")
		.. translate("Official website:") .. ' <a href=\"https://www.ui.com/\" target=\"_blank\">https://www.ui.com/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("UnifiController status:"))
s:append(Template("unifi/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Flag, "hostnet", translate("Host network"), translate("UnifiController running in host network, port is always 8443 if enabled"))
o.default = 0
o.rmempty = false

o = s:option(Value, "http_port", translate("HTTPS Port").."<b>*</b>")
o.default = "8083"
o.datatype = "string"
o:depends("hostnet", 0)

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("lscr.io/linuxserver/unifi-controller:latest", "lscr.io/linuxserver/unifi-controller:latest")
o.default = "lscr.io/linuxserver/unifi-controller:latest"

local blocks = unifi_model.blocks()
local home = unifi_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = unifi_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
