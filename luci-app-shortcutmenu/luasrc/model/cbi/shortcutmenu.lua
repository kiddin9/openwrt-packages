--[[
LuCI - Lua Configuration Interface

Copyright 2020 doushang <wsdosh@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

local sys = require "luci.sys"
local a,b,c,d

m = Map("shortcutmenu", translate("Shortcutmenu"),
        translatef("Shortcutmenu is used to provide quick access to web pages."))
s = m:section(TypedSection, "lists", translate("Lists"))
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true

a = s:option(Value, "webname", translate("Webname"))

b = s:option(Value,"weburl", translate("Weburl<font color=\"green\">(without http:// or https:// )</font>"))

c = s:option(Value,"webpath",translate("Webpath"))
c.default = '/'

d = s:option(DummyValue,"operator",translate("Operator"))
d.rawhtml = true
function d.cfgvalue(self, s)
	local e = self.map:get(s, "weburl") or ' '
	local f = self.map:get(s, "webpath") or ' '
	return "<input type='button' style='width:210px; border-color:Teal; text-align:center; font-weight:bold;color:Green;' value='Go' onclick=\"window.open('http://"..e..""..f.."')\"/>"
end

return m