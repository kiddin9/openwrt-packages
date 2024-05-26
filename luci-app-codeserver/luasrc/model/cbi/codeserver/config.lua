--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local codeserver_model = require "luci.model.codeserver"
local m, s, o

m = taskd.docker_map("codeserver", "codeserver", "/usr/libexec/istorec/codeserver.sh",
	translate("CodeServer"),
	translate("CodeServer is a web version of VSCode.")
		.. translate("Official website:") .. ' <a href=\"https://coder.com/\" target=\"_blank\">https://coder.com/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("CodeServer status:"))
s:append(Template("codeserver/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.default = "8085"
o.datatype = "string"

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("lscr.io/linuxserver/code-server:latest", "lscr.io/linuxserver/code-server:latest")
o:value("lscr.io/linuxserver/code-server:4.8.3", "lscr.io/linuxserver/code-server:4.8.3")
o.default = "lscr.io/linuxserver/code-server:latest"

local blocks = codeserver_model.blocks()
local home = codeserver_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = codeserver_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "env_password", "PASSWORD")
o.password = true
o.datatype = "string"

o = s:option(Value, "env_hashed_password", "HASHED_PASSWORD")
o.datatype = "string"
o.password = true

o = s:option(Value, "env_sudo_password", "SUDO_PASSWORD")
o.password = true
o.datatype = "string"

o = s:option(Value, "env_sudo_password_hash", "SUDO_PASSWORD_HASH")
o.password = true
o.datatype = "string"

o = s:option(Value, "env_proxy_domain", "PROXY_DOMAIN")
o.datatype = "string"

return m
