--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local owntone_model = require "luci.model.owntone"
local m, s, o

m = taskd.docker_map("owntone", "owntone", "/usr/libexec/istorec/owntone.sh",
	translate("Owntone"),
	translate("OwnTone is an open source (audio) media server which allows sharing and streaming your media library to iTunes (DAAP1), Roku (RSP), AirPlay devices (multiroom), Chromecast and also supports local playback.")
		.. translate("Official website:") .. ' <a href=\"https://owntone.github.io/owntone-server/\" target=\"_blank\">https://owntone.github.io/owntone-server/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Owntone status:"))
s:append(Template("owntone/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "image_name", translate("Image").."<b>*</b>", translate("Owntone only works in host network with port 3689"))
o.rmempty = false
o.datatype = "string"
o:value("lscr.io/linuxserver/daapd:latest", "lscr.io/linuxserver/daapd:latest")
o:value("lscr.io/linuxserver/daapd:28.5.20221103", "lscr.io/linuxserver/daapd:28.5.20221103")
o.default = "lscr.io/linuxserver/daapd:latest"

local blocks = owntone_model.blocks()
local home = owntone_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = owntone_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "music_path", translate("Music path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
local paths, default_path = owntone_model.find_paths(blocks, home, "Public")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
