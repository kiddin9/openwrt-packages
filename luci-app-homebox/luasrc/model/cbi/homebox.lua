
local m, s

m = Map("homebox", translate("Homebox"), translate("Homebox is a tool for local network speed testing"))

m:section(SimpleSection).template  = "homebox_status"

s=m:section(TypedSection, "homebox", translate("Global Settings"))
s.addremove=false
s.anonymous=true

s:option(Flag, "enabled", translate("Enable")).rmempty=false

return m


