-- 定义变量m、s、o
local m, s, o
-- 获取UCI配置项
local uci = luci.model.uci.cursor()
-- 创建一个名为 "broadband" 的配置项，设置标题和说明
m = Map("broadband", "%s - %s" %{translate("Broadband"), translate("Settings")}, translate("The network speed-up service is provided by the speed test network, with uplink and downlink speed-up functions, and the plug-in has the function of network uninterrupted acceleration."))
-- 添加一个名为 "status" 的模板
m:append(Template("broadband/status"))
-- 创建一个名为 "general" 的配置项，设置标题和说明
s = m:section(NamedSection, "general", "general", translate("General Settings"))
-- 隐藏“添加”和“删除”按钮
s.anonymous = true
s.addremove = false
-- 创建一个名为 "button_restart" 的按钮，用于重启插件
button_restart = s:option (Button, "_button_restart", translate("重启插件"))
button_restart.inputtitle = translate ( "点击重启")
button_restart.inputstyle = "apply"
-- 当按钮被点击时，执行重启插件的操作
function button_restart.write (self, section, value)
	luci.sys.exec("/etc/init.d/broadband restart > /dev/null")
end
-- 创建一个名为 "button_cleanlog" 的按钮，用于清理日志
button_cleanlog = s:option (Button, "_button_cleanlog", translate("日志清理"))
button_cleanlog.inputtitle = translate ( "点击清理")
button_cleanlog.inputstyle = "apply"
-- 当按钮被点击时，执行清理日志的操作
function button_cleanlog.write (self, section, value)
	luci.sys.exec("cat /dev/null > /var/log/broadband.log > /dev/null")
end
-- 创建一个名为 "enabled" 的复选框，用于启用插件
o = s:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false
-- 创建一个名为 "logging" 的复选框，用于启用日志记录
o = s:option(Flag, "logging", translate("Enable Logging"))
-- 创建一个名为 "network" 的下拉框，用于选择升级接口
o = s:option(ListValue, "network", translate("Upgrade interface"),translate("It is not recommended to increase the speed of non-dial-up interfaces, and the acceleration may be interrupted"))
-- 遍历所有网络接口，将它们添加到下拉框中
uci:foreach("network","interface",function(section)
	if section[".name"]~="loopback" then
		o:value(section[".name"])
	end
end)
-- 创建一个名为 "more" 的复选框，用于显示更多选项
s:option(Flag, "more", translate("More Options"),
	translate("Options for advanced users"))
-- 创建一个名为 "verbose" 的复选框，用于启用详细日志记录
o = s:option(Flag, "verbose", translate("Enable verbose logging"))
o:depends("more", 1)
-- 返回配置项
return m
