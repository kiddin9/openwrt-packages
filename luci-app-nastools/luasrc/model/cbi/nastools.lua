--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local nastools_model = require "luci.model.nastools"
local m, s, o

m = taskd.docker_map("nastools", "nastools", "/usr/libexec/istorec/nastools.sh",
	translate("NasTools"),
	translate("NasTools is a tools for resource aggregation running in NAS.")
		.. translate("Official website:") .. ' <a href=\"https://github.com/jxxghp/nas-tools\" target=\"_blank\">https://github.com/jxxghp/nas-tools</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("NasTools status:"))
s:append(Template("nastools/status"))

s = m:section(TypedSection, "nastools", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("Port").."<b>*</b>")
o.rmempty = false
o.default = "3003"
o.datatype = "port"

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("jxxghp/nas-tools", "jxxghp/nas-tools")
o:value("sungamma/nas-tools:2.9.1", "sungamma/nas-tools:2.9.1")
o.default = "sungamma/nas-tools:2.9.1"

local blocks = nastools_model.blocks()
local home = nastools_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = nastools_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Flag, "auto_upgrade", translate("Auto update"))
o.default = 1
o.rmempty = false

return m
