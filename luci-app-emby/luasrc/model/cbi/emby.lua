--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local emby_model = require "luci.model.emby"
local m, s, o

m = taskd.docker_map("emby", "emby", "/usr/libexec/istorec/emby.sh",
	translate("Emby"),
	translate("Emby brings together your personal videos, music, photos, and live television.")
		.. translate("Official website:") .. ' <a href=\"https://emby.media/\" target=\"_blank\">https://emby.media/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Emby status:"))
s:append(Template("emby/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Flag, "hostnet", translate("Host network"), translate("Emby running in host network, for DLNA application, port is always 8096 if enabled"))
o.default = 0
o.rmempty = false

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.default = "8097"
o.datatype = "port"
o:depends("hostnet", 0)

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("emby/embyserver", "emby/embyserver")
o:value("emby/embyserver:4.8.0.59", "emby/embyserver:4.8.0.59")
o:value("emby/embyserver_arm32v7", "emby/embyserver_arm32v7")
o:value("emby/embyserver_arm64v8", "emby/embyserver_arm64v8")
o.default = "emby/embyserver"

local blocks = emby_model.blocks()
local home = emby_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = emby_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "media_path", translate("Media path"), translate("Not required, all disk is mounted in") .. " <a href='/cgi-bin/luci/admin/services/linkease/file/?path=/root/mnt' target='_blank'>/mnt</a>")
o.datatype = "string"

o = s:option(Value, "cache_path", translate("Transcode cache path"), translate("Default use 'transcodes' in 'config path' if not set, please make sure there has enough space"))
o.datatype = "string"
local paths, default_path = emby_model.find_paths(blocks, home, "Caches")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
