--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local vaultwarden_model = require "luci.model.vaultwarden"
local m, s, o

m = taskd.docker_map("vaultwarden", "vaultwarden", "/usr/libexec/istorec/vaultwarden.sh",
	translate("Vaultwarden"),
	translate("Vaultwarden is an alternative implementation of the Bitwarden server API written in Rust and compatible with upstream Bitwarden clients.")
		.. translate("Official website:") .. ' <a href=\"https://github.com/dani-garcia/vaultwarden\" target=\"_blank\">https://github.com/dani-garcia/vaultwarden</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Vaultwarden status:"))
s:append(Template("vaultwarden/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.default = "8097"
o.datatype = "port"

o = s:option(Value, "notify_port", translate("Notify Port"))
o.datatype = "port"

o = s:option(Flag, "signup_allowed", "SIGNUP_ALLOWED")
o.default = 0

o = s:option(Value, "admin_token", "ADMIN_TOKEN")
o.default = ""
o.password = true

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("vaultwarden/server:latest", "vaultwarden/server:latest")
o:value("vaultwarden/server:1.26.0", "vaultwarden/server:1.26.0")
o.default = "vaultwarden/server:latest"

local blocks = vaultwarden_model.blocks()
local home = vaultwarden_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = vaultwarden_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
