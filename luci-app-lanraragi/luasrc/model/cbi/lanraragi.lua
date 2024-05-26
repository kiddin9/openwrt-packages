--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local lanraragi_model = require "luci.model.lanraragi"
local m, s, o

m = taskd.docker_map("lanraragi", "lanraragi", "/usr/libexec/istorec/lanraragi.sh",
	translate("LANraragi"), 
	translate("LANraragi is Open source server for archival of comics/manga. ")
    .. translate("Default Password:") .. ' kamimamita '
		.. translate("Official website:") .. ' <a href=\"https://github.com/Difegue/LANraragi\" target=\"_blank\">https://github.com/Difegue/LANraragi</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("LANraragi status:"))
s:append(Template("lanraragi/status"))

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
o:value("dezhao/lanraragi_cn", "dezhao/lanraragi_cn")
o:value("dezhao/lanraragi_cn:0.8.6", "dezhao/lanraragi_cn:0.8.6")
o.default = "dezhao/lanraragi_cn"

local blocks = lanraragi_model.blocks()
local home = lanraragi_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = lanraragi_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "content_path", translate("Content path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
local paths, default_path = lanraragi_model.find_paths(blocks, home, "Public")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
