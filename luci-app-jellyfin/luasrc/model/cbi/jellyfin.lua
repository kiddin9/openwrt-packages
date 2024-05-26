--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local jellyfin_model = require "luci.model.jellyfin"
local m, s, o

m = taskd.docker_map("jellyfin", "jellyfin", "/usr/libexec/istorec/jellyfin.sh",
	translate("Jellyfin"),
	translate("Jellyfin is the volunteer-built media solution that puts you in control of your media. Stream to any device from your own server, with no strings attached. Your media, your server, your way.")
		.. translate("Official website:") .. ' <a href=\"https://jellyfin.org/\" target=\"_blank\">https://jellyfin.org/</a>'
		.. "<dl><dt>" .. translate("The following models support hardware transcoding without configuration in Jellyfin:") .. "</dt>"
		.. "<dd>- Easepi ARS2</dd>"
		.. "<dd>- " .. translate("RK35xx series (e.g. R6S, R5S, R68s, R66s, H28K, etc.) with iStoreOS firmware (version 20221123 and above). Other firmwares require MPP and RGA to be turned on, and are not guaranteed to be available.") .. "</dd>"
		.. "<dt>" .. translate("The following models may support hardware transcoding by referring to the official Jellyfin documentation:") .. "</dt>"
		.. "<dd>- " .. translate("x86 series") .. "</dd>"
		.. "<dd>- " .. translate("Raspberry Pi series") .. "</dd>"
		.. "</dl>")

s = m:section(SimpleSection, translate("Service Status"), translate("Jellyfin status:"))
s:append(Template("jellyfin/status"))

s = m:section(TypedSection, "jellyfin", translate("Setup"),
		translate("The initial installation of Jellyfin requires at least 2GB of space, please make sure that the Docker data directory has enough space. It is recommended to migrate Docker to a hard drive before installing Jellyfin.") 
		.. "<br>" .. translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Flag, "hostnet", translate("Host network"), translate("Jellyfin running in host network, for DLNA application, port is always 8096 if enabled"))
o.default = 0
o.rmempty = false

o = s:option(Value, "port", translate("Port").."<b>*</b>")
o.default = "8096"
o.datatype = "port"
o:depends("hostnet", 0)

local blocks = jellyfin_model.blocks()
local home = jellyfin_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = jellyfin_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "media_path", translate("Media path"), translate("Not required, all disk is mounted in") .. " <a href='/cgi-bin/luci/admin/services/linkease/file/?path=/root/mnt' target='_blank'>/mnt</a>")
o.datatype = "string"

o = s:option(Value, "cache_path", translate("Transcode cache path"), translate("Default use 'transcodes' in 'config path' if not set, please make sure there has enough space"))
o.datatype = "string"
local paths, default_path = jellyfin_model.find_paths(blocks, home, "Caches")
for _, val in pairs(paths) do
  o:value(val, val)
end

return m
