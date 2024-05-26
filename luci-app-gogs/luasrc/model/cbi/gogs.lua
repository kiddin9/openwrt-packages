--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local gogs_model = require "luci.model.gogs"
local m, s, o

m = taskd.docker_map("gogs", "gogs", "/usr/libexec/istorec/gogs.sh",
	translate("Gogs"),
	translate("Gogs is a painless self-hosted Git service.")
		.. translate("Official website:") .. ' <a href=\"https://gogs.io/\" target=\"_blank\">https://gogs.io/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Gogs status:"))
s:append(Template("gogs/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.default = "3001"
o.datatype = "string"
o.rmempty = false

o = s:option(Value, "ssh_port", translate("SSH Port").."<b>*</b>")
o.default = "3022"
o.datatype = "string"
o.rmempty = false

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("gogs/gogs:latest", "gogs/gogs:latest")
o:value("gogs/gogs:0.12", "gogs/gogs:0.12")
o.default = "gogs/gogs:latest"

local blocks = gogs_model.blocks()
local home = gogs_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = gogs_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
