--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local m, s

m = Map("mymind",
	translate("MyMind"),
	translate("MyMind is mind editor.")
		.. translate("Official website:") .. ' <a href=\"https://github.com/ondras/my-mind\" target=\"_blank\">https://github.com/ondras/my-mind</a>')

s = m:section(SimpleSection, translate("MyMind Web"), translate("MyMind Web:"))
s:append(Template("mymind/status"))

return m
