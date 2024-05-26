--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local penpot_model = require "luci.model.penpot"
local m, s, o

m = taskd.docker_map("penpot", "penpot", "/usr/libexec/istorec/penpot.sh",
	translate("Penpot"),
	translate("Penpot is the first Open Source design and prototyping platform meant for cross-domain teams.")
		.. translate("Official website:") .. ' <a href=\"https://penpot.app/\" target=\"_blank\">https://penpot.app/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Penpot status:"))
s:append(Template("penpot/status"))

s = m:section(TypedSection, "main", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "http_port", translate("HTTP Port").."<b>*</b>")
o.default = "9001"
o.datatype = "string"

local blocks = penpot_model.blocks()
local home = penpot_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>", translate("Manually edit template at") .. " <a href='/cgi-bin/luci/admin/services/linkease/file/?path=/root/usr/share/penpot' target='_blank'>/root/usr/share/penpot</a>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = penpot_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "public_uri", "PUBLIC_URI")
o.datatype = "string"

o = s:option(Value, "redis_uri", "REDIS_URI")
o.datatype = "string"

o = s:option(Value, "db_uri", "DB_URI")
o.datatype = "string"

o = s:option(Value, "db_name", "DB_NAME")
o.datatype = "string"

o = s:option(Value, "db_username", "DB_USERNAME")
o.datatype = "string"

o = s:option(Value, "db_password", "DB_PASSWORD")
o.password = true
o.datatype = "string"

o = s:option(Value, "smtp_default_from", "SMTP_DEFAULT_FROM")
o.datatype = "string"

o = s:option(Value, "smtp_default_reply_to", "SMTP_DEFAULT_REPLY_TO")
o.datatype = "string"

return m
