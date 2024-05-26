--[[
LuCI - Lua Configuration Interface
 Copyright (C) 2022-2024  sirpdboy <herboy2008@gmail.com> https://github.com/sirpdboy/luci-app-advancedplus
]]--

local fs = require "nixio.fs"
local uci=luci.model.uci.cursor()
local m,s,e

m = Map("advancedplus")
m.title = translate("Loading plugins")
m.description = translate("Choose to load and install the app store, DOCKER, all drivers, etc")..
translate("</br>For specific usage, see:")..translate("<a href=\'https://github.com/sirpdboy/luci-app-advancedplus.git' target=\'_blank\'>GitHub @sirpdboy/luci-app-advancedplus </a>")
m.apply_on_parse=true

s=m:section(TypedSection, "basic", "")
s.anonymous=true

e=s:option(ListValue,'select_ipk', translate('Select the type of loading'))
e:value("istore", translate("Install iStore"))
e:value("docker", translate("Install Docker"))
e:value("drv", translate("Install All drives"))
e.default="istore"

e=s:option(Button, "restart", translate("Perform operation"))
e.inputtitle=translate("Click to execute")
e.template ='advancedplus/advanced'

return m
