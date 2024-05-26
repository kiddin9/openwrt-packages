
local fs = require "nixio.fs"
local uci=luci.model.uci.cursor()
local a, t, e
a = Map("advancedplus")
a.title = translate("Advanced Setting")
a.description = translate("The enhanced version of the original advanced settings allows for unified setting and management of background images for kucat/Agron/Opentopd themes, without the need to upload them separately. Color schemes for kucat/Agron/design themes can be set.<br>")..
translate("At the same time, important plugin parameters can be compiled. At the same time, some system parameters can also be set, such as display and hide settings.")..
translate("</br>For specific usage, see:")..translate("<a href=\'https://github.com/sirpdboy/luci-app-advancedplus.git' target=\'_blank\'>GitHub @sirpdboy/luci-app-advancedplus </a>")

t = a:section(TypedSection, "basic", translate("Settings"))
t.anonymous = true
e = t:option(Flag, "qos",translate('Qos automatic optimization'), translate('Enable QOS automatic optimization strategy (testing function)'))
e.default = "0"
e.rmempty = false

dl = t:option(Value, "download", translate("Download bandwidth(Mbit/s)"))
dl.default = '200'
dl:depends("qos", true)

ul = t:option(Value, "upload", translate("Upload bandwidth(Mbit/s)"))
ul.default = '30'
ul:depends("qos", true)

e = t:option(Flag, "uhttps",translate('Accessing using HTTPS'), translate('Open the address in the background and use HTTPS for secure access'))

if fs.access('/usr/bin/zsh') then
e = t:option(Flag, "usshmenu",translate('No backend menu required'), translate('OPENWRT backend and SSH login do not display shortcut menus'))
end

e = t:option(Flag, "tsoset",translate('TSO optimization for network card interruption'), translate('Turn off the TSO parameters of the INTEL225 network card to improve network interruption'))
e.default = "1"
e.rmempty = false

e = t:option(Flag, "set_ttyd",translate('Allow TTYD external network access'))
e.default = "0"

e = t:option(Flag, "set_firewall_wan",translate('Set firewall wan to open'))
e.default = "0"

e = t:option(Flag, "dhcp_domain",translate('Add Android host name mapping'), translate('Resolve the issue of Android native TV not being able to connect to WiFi for the first time'))
e.default = "0"

return a
