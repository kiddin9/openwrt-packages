--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local xunlei_model = require "luci.model.xunlei"
local m, s, o

m = taskd.docker_map("xunlei", "xunlei", "/usr/libexec/istorec/xunlei.sh",
	translate("Xunlei"),
	translate("Xunlei is an download tool, made by Xunlei, Inc.")
		.. translate("Official website:") .. ' <a href=\"https://www.xunlei.com/\" target=\"_blank\">https://www.xunlei.com/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Xunlei status:"))
s:append(Template("xunlei/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Flag, "hostnet", translate("Host network"), translate("Xunlei running in host network, port is always 2345 if enabled"))
o.default = 0
o.rmempty = false

o = s:option(Value, "port", translate("Port").."<b>*</b>")
o.default = "2345"
o.datatype = "port"
o:depends("hostnet", 0)

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("registry.cn-shenzhen.aliyuncs.com/cnk3x/xunlei:latest", "registry.cn-shenzhen.aliyuncs.com/cnk3x/xunlei:latest")
o:value("cnk3x/xunlei:latest", "cnk3x/xunlei:latest")
o.default = "registry.cn-shenzhen.aliyuncs.com/cnk3x/xunlei:latest"

local blocks = xunlei_model.blocks()
local home = xunlei_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = xunlei_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "dl_path", translate("Download path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = xunlei_model.find_paths(blocks, home, "Public")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
