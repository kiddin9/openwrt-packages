require("luci.util")

mp = Map("lingti", translate("LingTi Game Accelerator"))
mp.description = translate("A Paid Game Acceleration service, Please use with Mobile App")
mp:section(SimpleSection).template  = "lingti/lingti_status"

s = mp:section(TypedSection, "lingti")
s.anonymous=true
s.addremove=false

o = s:option(Flag, "enabled", translate("Enable"))
o.default = 0
o.optional = false

local apply = luci.http.formvalue("cbi.apply")
if apply then
    io.popen("/etc/init.d/lingti_luci start &")
end

return mp
