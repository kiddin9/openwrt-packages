local i = require "luci.sys"
local t, e
t = Map("wolplus", translate("wolplus"), translate("Wake up your LAN device") .. [[<br /><br /><a href="https://github.com/sundaqiang/openwrt-packages" target="_blank">Powered by sundaqiang</a>]])
t.template = "wolplus/index"
e = t:section(TypedSection, "macclient", translate("macclient"))
e.template = "cbi/tblsection"
e.anonymous = true
e.addremove = true
a = e:option(Value, "name", translate("name"))
a.optional = false
nolimit_mac = e:option(Value, "macaddr", translate("macaddr"))
nolimit_mac.rmempty = false
i.net.mac_hints(function(e, t) nolimit_mac:value(e, "%s (%s)" % {e, t}) end)
nolimit_eth = e:option(Value, "maceth", translate("maceth"))
nolimit_eth.rmempty = false
for t, e in ipairs(i.net.devices()) do if e ~= "lo" then nolimit_eth:value(e) end end
btn = e:option(Button, "_awake",translate("awake"))
btn.inputtitle	= translate("awake")
btn.inputstyle	= "apply"
btn.disabled	= false
btn.template = "wolplus/awake"
function gen_uuid(format)
    local uuid = i.exec("echo -n $(cat /proc/sys/kernel/random/uuid)")
    if format == nil then
        uuid = string.gsub(uuid, "-", "")
    end
    return uuid
end
function e.create(e, t)
    local uuid = gen_uuid()
    t = uuid
    TypedSection.create(e, t)
end

return t
