--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local homeassistant_model = require "luci.model.homeassistant"
local m, s, o

m = taskd.docker_map("homeassistant", "homeassistant", "/usr/libexec/istorec/homeassistant.sh",
	translate("Home Assistant"),
	translate("Open source home automation that puts local control and privacy first. Powered by a worldwide community of tinkerers and DIY enthusiasts.")
		.. translate("Official website:") .. ' <a href=\"https://www.home-assistant.io/\" target=\"_blank\">https://www.home-assistant.io/</a>')

s = m:section(SimpleSection, translate("Service Status"), translate("Home Assistant status:"))
s:append(Template("homeassistant/status"))

s = m:section(TypedSection, "homeassistant", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("homeassistant/home-assistant:latest", "homeassistant/home-assistant:latest")
o:value("homeassistant/home-assistant:2023.3.3", "homeassistant/home-assistant:2023.3.3")
o:value("homeassistant/home-assistant:dev", "homeassistant/home-assistant:dev")
o:value("ghcr.io/home-assistant/home-assistant:stable", "ghcr.io/home-assistant/home-assistant:stable")
o:value("ghcr.io/home-assistant/home-assistant:2023.3.3", "ghcr.io/home-assistant/home-assistant:2023.3.3")
o.default = "homeassistant/home-assistant:latest"

local blocks = homeassistant_model.blocks()
local home = homeassistant_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = homeassistant_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "time_zone", translate("Timezone"))
o.datatype = "string"
o:value("Asia/Shanghai", "Asia/Shanghai")

return m
