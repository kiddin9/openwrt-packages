m = Map("autoupdate", translate("AutoUpdate"),
translate("AutoUpdate LUCI supports scheduled upgrade & one-click firmware upgrade")
.. [[<br /><br /><a href="https://github.com/Hyy2001X/AutoBuild-Actions-BETA">]]
.. translate("Powered by AutoBuild-Actions")
.. [[</a>]]
)

s = m:section(TypedSection, "autoupdate")
s.anonymous = true

local default_url = luci.sys.exec("autoupdate --env Github")
local default_flag = luci.sys.exec("autoupdate --env TARGET_FLAG")
local default_logpath = luci.sys.exec("autoupdate --env Log_Path")

enable = s:option(Flag, "enable", translate("Enable"), translate("Automatically update firmware during the specified time when Enabled"))
enable.default = 0
enable.optional = false

proxy = s:option(Flag, "proxy", translate("Preference Mirror Speedup"), translate("Preference Mirror for speeding up download"))
proxy.default = 1
proxy:depends("enable", "1")
proxy.optional = false

proxy_type = s:option(ListValue, "proxy_type", translate("Mirror Station"))
proxy_type.default = "A"
proxy_type:value("A", translate("Automatic selection (Recommend)"))
proxy_type:value("G", translate("GitHub Proxy"))
proxy_type:value("F", translate("CF Workers"))
proxy_type:depends("proxy", "1")
proxy_type.optional = false

advanced = s:option(Flag, "advanced", translate("Advanced Settings"))
advanced.default = 0
advanced:depends("enable", "1")

advanced_settings = s:option(MultiValue, "advanced_settings", translate("Advanced Settings"), translate("Supported Multi Selection"))
advanced_settings:value("--skip-verify", translate("Skip SHA256 Verify"))
advanced_settings:value("-F", translate("Force Flash Firmware"))
advanced_settings:value("--decompress", translate("Decompress [img.gz] Firmware"))
advanced_settings:value("-n", translate("Upgrade without keeping config"))
advanced_settings:depends("advanced", "1")
advanced.description = translate("Please don't select it unless you know what you're doing!")

week = s:option(ListValue, "week", translate("Update Day"), translate("Recommend to set the AUTOUPDATE time to an uncommon time"))
week:value(7, translate("Everyday"))
week:value(1, translate("Monday"))
week:value(2, translate("Tuesday"))
week:value(3, translate("Wednesday"))
week:value(4, translate("Thursday"))
week:value(5, translate("Friday"))
week:value(6, translate("Saturday"))
week:value(0, translate("Sunday"))
week.default = 0
week:depends("enable", "1")

hour = s:option(Value, "hour", translate("Hour"))
hour.datatype = "range(0,23)"
hour.rmempty = true
hour.default = 0
hour:depends("enable", "1")

minute = s:option(Value, "minute", translate("Minute"))
minute.datatype = "range(0,59)"
minute.rmempty = true
minute.default = 30
minute:depends("enable", "1")

github = s:option(Value, "github", translate("Github Url"), translate("For detecting cloud version and downloading firmware"))
github.default = default_url
github.rmempty = false

flag = s:option(Value, "flag", translate("Firmware Flag"))
flag.default = default_flag
flag.rmempty = false

logpath = s:option(Value, "logpath", translate("Log Path"))
logpath.default = default_logpath
logpath.rmempty = false

return m
