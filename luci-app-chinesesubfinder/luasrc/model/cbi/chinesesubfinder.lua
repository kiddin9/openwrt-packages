--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local chinesesubfinder_model = require "luci.model.chinesesubfinder"
local m, s, o

m = taskd.docker_map("chinesesubfinder", "chinesesubfinder", "/usr/libexec/istorec/chinesesubfinder.sh",
	translate("ChineseSubFinder"),
	translate("ChineseSubFinder is a tool which can download chinese subtitle automaticly.")
		.. translate("Official website:") .. ' <a href=\"https://github.com/allanpk716/ChineseSubFinder\" target=\"_blank\">https://github.com/allanpk716/ChineseSubFinder</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("ChineseSubFinder status:"))
s:append(Template("chinesesubfinder/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.rmempty = false
o.default = "19035"
o.datatype = "string"

o = s:option(Value, "web_port", "WEB Port<b>*</b>")
o.rmempty = false
o.default = "19037"
o.datatype = "string"

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("allanpk716/chinesesubfinder:latest-lite", "allanpk716/chinesesubfinder:latest-lite")
o:value("allanpk716/chinesesubfinder:v0.43.1-lite", "allanpk716/chinesesubfinder:v0.43.1-lite")
o.default = "allanpk716/chinesesubfinder:latest-lite"

local blocks = chinesesubfinder_model.blocks()
local home = chinesesubfinder_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = chinesesubfinder_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "media_path", translate("Media path"), translate("Not required, all disk is mounted in") .. " <a href='/cgi-bin/luci/admin/services/linkease/file/?path=/root/mnt' target='_blank'>/mnt</a>")
o.datatype = "string"

return m
