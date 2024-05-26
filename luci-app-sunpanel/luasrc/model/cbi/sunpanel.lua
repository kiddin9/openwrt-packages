--xiaobao <xiaobao@linkease.com> ,20240223


local block_model = require "luci.model.sunpanel"
local m, s, o

m = Map("sunpanel", translate("SunPanel"), translate("Server, NAS navigation panel, Homepage, Browser homepage. Login:") .. "admin@sun.cc/12345678"
    .. translate("Official website:") .. ' <a href=\"https://sun-panel-doc.enianteam.com/\" target=\"_blank\">https://sun-panel-doc.enianteam.com/</a>')

m:section(SimpleSection).template  = "sunpanel/status"

s=m:section(TypedSection, "sunpanel", translate("Global settings"))
s.addremove=false
s.anonymous=true

s:option(Flag, "enabled", translate("Enable")).rmempty=false

s:option(Value, "port", translate("Port")).rmempty=false

local blocks = block_model.blocks()
local home = block_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = block_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m


