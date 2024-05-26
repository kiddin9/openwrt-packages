local a, t, e
local opacity_sets = {
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    20
}

local ts_sets = {
    0,
    0.05,
    0.1,
    0.2,
    0.3,
    0.4,
    0.5,
    0.6,
    0.7,
    0.8,
    0.9,
    0.95,
    1
}
a = Map("advancedplus")
a.title = translate("KuCat Theme Config")
a.description = translate("Set and manage features such as KuCat themed background wallpaper, main background color, partition background, transparency, blur, toolbar retraction and shortcut pointing.</br>")..
translate("There are 6 preset color schemes, and only the desktop background image can be set to display or not. The custom color values are RGB values such as 255,0,0 (representing red), and a blur radius of 0 indicates no lag in the image.")..
translate("</br>For specific usage, see:")..translate("<a href=\'https://github.com/sirpdboy/luci-app-advancedplus.git' target=\'_blank\'>GitHub @sirpdboy/luci-app-advancedplus </a>")
t = a:section(TypedSection, "basic", translate("Settings"))
t.anonymous = true

e = t:option(ListValue, 'background', translate('Wallpaper Source'),translate('Local wallpapers need to be uploaded on their own, and only the first update downloaded on the same day will be automatically downloaded.'))
e:value('0', translate('Local wallpaper'))
e:value('1', translate('Auto download Iciba wallpaper'))
e:value('2', translate('Auto download unsplash wallpaper'))
e:value('3', translate('Auto download Bing wallpaper'))
e:value('4', translate('Auto download Bird 4K wallpaper'))
e.default = '0'
e.rmempty = false

e = t:option(Flag, "bklock", translate("Wallpaper synchronization"),translate("Is the login wallpaper consistent with the desktop wallpaper? If not selected, it indicates that the desktop wallpaper and login wallpaper are set independently."))
e.rmempty = false
e.default = '0'

e = t:option(Flag, "setbar", translate("Expand Toolbar"),translate('Expand or shrink the toolbar'))
e.rmempty = false
e.default = '0'

e = t:option(Flag, "bgqs", translate("Refreshing mode"),translate('Cancel background glass fence special effects'))
e.rmempty = false
e.default = '0'

e = t:option(Flag, "dayword", translate("Enable Daily Word"))
e.rmempty = false
e.default = '0'

e = t:option(Value, 'gohome', translate('Status Homekey settings'))
e:value('overview', translate('Overview'))
e:value('online', translate('Online User'))
e:value('realtime', translate('Realtime Graphs'))
e:value('netdata', translate('NetData'))
e.default = 'overview'
e.rmempty = false

e = t:option(Value, 'gouser', translate('System Userkey settings'))
e:value('advancedplus', translate('Advanced plus'))
e:value('netwizard', translate('Inital Setup'))
e:value('system', translate('System'))
e:value('admin', translate('Administration'))
e:value('terminal', translate('TTYD Terminal'))
e:value('packages', translate('Software'))
e:value('filetransfer', translate('FileTransfer'))
e.default = 'advancedplus'
e.rmempty = false

e = t:option(Value, 'gossr', translate('Services Ssrkey settings'))
e:value('shadowsocksr', translate('SSR'))
e:value('bypass', translate('bypass'))
e:value('vssr', translate('Hello World'))
e:value('passwall', translate('passwall'))
e:value('passwall2', translate('passwall2'))
e:value('openclash', translate('OpenClash'))
e:value('chatgpt-web', translate('Chatgpt Web'))
e:value('ddns-go', translate('DDNS-GO'))
e.default = 'bypass'
e.rmempty = false

e = t:option(Flag, "fontmode", translate("Care mode (large font)"))
e.rmempty = false
e.default = '0'

t = a:section(TypedSection, "theme", translate("Color scheme list"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true

e = t:option(Value, 'remarks', translate('Remarks'))

e = t:option(Flag, "use", translate("Enable color matching"))
e.rmempty = false
e.default = '1'

e = t:option(ListValue, 'mode', translate('Theme mode'))
e:value('auto', translate('Auto'))
e:value('light', translate('Light'))
e:value('dark', translate('Dark'))
e.default = 'light'

e = t:option(Value, 'primary_rgbm', translate('Main Background color(RGB)'))
e:value("blue",translate("RoyalBlue"))
e:value("green",translate("MediumSeaGreen"))
e:value("orange",translate("SandyBrown"))
e:value("red",translate("TomatoRed"))
e:value("black",translate("Black tea eye protection gray"))
e:value("gray",translate("Cool night time(gray and dark)"))
e:value("bluets",translate("Cool Ocean Heart (transparent and bright)"))
e.default='green'
e.datatype = ufloat
e.default='74,161,133'

e = t:option(Flag, "bkuse", translate("Enable wallpaper"))
e.rmempty = false
e.default = '1'

e = t:option(Value, 'primary_rgbm_ts', translate('Wallpaper transparency'))
for _, v in ipairs(ts_sets) do
    e:value(v)
end
e.datatype = ufloat
e.rmempty = false

e.default='0.5'

e = t:option(Value, 'primary_opacity', translate('Wallpaper blur radius'))
for _, v in ipairs(opacity_sets) do
    e:value(v)
end
e.datatype = ufloat
e.rmempty = false

e.default='10'

e = t:option(Value, 'primary_rgbs', translate('Fence background(RGB)'))
e.default='225,112,88'
e.datatype = ufloat

e = t:option(Value, 'primary_rgbs_ts', translate('Fence background transparency'))
for _, v in ipairs(ts_sets) do
    e:value(v)
end
e.datatype = ufloat
e.rmempty = false

e.default='0.3'

a.apply_on_parse = true
a.on_after_apply = function(self,map)
	luci.sys.exec("/etc/init.d/advancedplus start >/dev/null 2>&1")
	luci.http.redirect(luci.dispatcher.build_url("admin","system","advancedplus","kucatset"))
end

return a
