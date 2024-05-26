--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local webvirtcloud_model = require "luci.model.webvirtcloud"
local m, s, o

m = taskd.docker_map("webvirtcloud", "webvirtcloud", "/usr/libexec/istorec/webvirtcloud.sh",
	translate("KVM WebVirtCloud"),
	translate("KVM web manager in iStoreOS using webvirtcloud.") .. " login: admin/admin. " 
		.. translate("Official website:") .. ' <a href=\"https://webvirt.cloud/\" target=\"_blank\">https://webvirt.cloud/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("WebVirtCloud status:"))
s:append(Template("webvirtcloud/status"))

s = m:section(TypedSection, "webvirtcloud", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.default = "6009"
o.datatype = "port"

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("linkease/webvirtcloud:latest", "linkease/webvirtcloud:latest")
o:value("linkease/webvirtcloud:0.3.6", "linkease/webvirtcloud:0.3.6")
o.default = "linkease/webvirtcloud:latest"

local blocks = webvirtcloud_model.blocks()
local home = webvirtcloud_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = webvirtcloud_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "time_zone", translate("Timezone"))
o.datatype = "string"
o:value("Asia/Shanghai", "Asia/Shanghai")

return m
