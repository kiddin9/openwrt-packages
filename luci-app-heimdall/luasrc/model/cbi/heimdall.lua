--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local m, s, o

m = taskd.docker_map("heimdall", "heimdall", "/usr/libexec/istorec/heimdall.sh",
	translate("Heimdall"),
	translate("Heimdall is an elegant solution to organise all your web applications.")
		.. translate("Official website:") .. ' <a href=\"https://github.com/linuxserver/Heimdall\" target=\"_blank\">https://github.com/linuxserver/Heimdall</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Heimdall status:"))
s:append(Template("heimdall/status"))

s = m:section(TypedSection, "heimdall", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.rmempty = false
o.default = "8088"
o.datatype = "port"

o = s:option(Value, "https_port", translate("HTTPS Port").."<b>*</b>")
o.rmempty = false
o.default = "8089"
o.datatype = "port"

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.default = "/root/heimdall/config"
o.datatype = "string"

return m
