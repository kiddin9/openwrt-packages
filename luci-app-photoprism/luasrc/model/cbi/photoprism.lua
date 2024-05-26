--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local photoprism_model = require "luci.model.photoprism"
local m, s, o

m = taskd.docker_map("photoprism", "photoprism", "/usr/libexec/istorec/photoprism.sh",
	translate("PhotoPrism"),
	translate("PhotoPrism® is an AI-Powered Photos App for the Decentralized Web. ") 
    .. translate("Default User:") .. ' admin '
		.. translate("Official website:") .. ' <a href=\"https://photoprism.app/\" target=\"_blank\">https://photoprism.app/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("PhotoPrism status:"))
s:append(Template("photoprism/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.rmempty = false
o.default = "2342"
o.datatype = "string"

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("photoprism/photoprism:latest", "photoprism/photoprism:latest")
o:value("photoprism/photoprism:221105-armv7", "photoprism/photoprism:221105-armv7")
o.default = "photoprism/photoprism:latest"

o = s:option(Value, "password", translate("Default Password").."<b>*</b>", translate("Only works on first install or after using a fresh 'Config path'"))
o.password = true
o.rmempty = false
o.datatype = "string"

local blocks = photoprism_model.blocks()
local home = photoprism_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = photoprism_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "picture_path", translate("Photo path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
local paths, default_path = photoprism_model.find_paths(blocks, home, "Public")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m

