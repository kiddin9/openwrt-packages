--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local memos_model = require "luci.model.memos"
local m, s, o

m = taskd.docker_map("memos", "memos", "/usr/libexec/istorec/memos.sh",
	translate("Memos"),
	translate("Memos is an open-source, self-hosted memo hub with knowledge management and collaboration.")
		.. translate("Official website:") .. ' <a href=\"https://usememos.com/\" target=\"_blank\">https://usememos.com/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Memos status:"))
s:append(Template("memos/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.default = "5230"
o.datatype = "port"

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("neosmemo/memos:latest", "neosmemo/memos:latest")
o.default = "neosmemo/memos:latest"

local blocks = memos_model.blocks()
local home = memos_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = memos_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
