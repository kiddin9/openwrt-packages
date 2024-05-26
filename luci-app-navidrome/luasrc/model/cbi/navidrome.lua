--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local navidrome_model = require "luci.model.navidrome"
local m, s, o

m = taskd.docker_map("navidrome", "navidrome", "/usr/libexec/istorec/navidrome.sh",
	translate("Navidrome"),
	translate("Navidrome is an open source web-based music collection server and streamer.")
		.. translate("Official website:") .. ' <a href=\"https://github.com/Difegue/Navidrome\" target=\"_blank\">https://github.com/Difegue/Navidrome</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Navidrome status:"))
s:append(Template("navidrome/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.rmempty = false
o.default = "3000"
o.datatype = "string"

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("difegue/navidrome", "difegue/navidrome")
o.default = "difegue/navidrome"

local blocks = navidrome_model.blocks()
local home = navidrome_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = navidrome_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "music_path", translate("Music path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
local paths, default_path = navidrome_model.find_paths(blocks, home, "Public")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
