local o=require"luci.dispatcher"
local e=require("luci.model.ipkg")
local s=require"nixio.fs"
local e=luci.model.uci.cursor()
local m,s,e

m=Map("autotimeset",translate("Scheduled task/startup task settings"),translate("<b>The original [Timing Settings] includes scheduled task execution and startup task execution. Presets include over 10 functions, including restart, shutdown, network restart, memory release, system cleaning, network sharing, network shutdown, automatic detection of network disconnects and reconnection, MWAN3 load balancing detection of reconnection, and custom scripts</b></br>") ..
translate("N1-N5 is continuous, N1, N3, N5 is discontinuous, */N represents every N hours or every N minutes.The week can only be 0~6, the hour can only be 0~23, the minute can only be 0~59, the unavailable time is 48 hours."))

s = m:section(TypedSection, 'global')
s.anonymous=true

e=s:option(TextValue, "customscript" ,translate("Edit Custom Script"))
e.description = translate("The execution content of the [Scheduled Customscript] in the task name")
e.rows = 5
e.default=" "

e=s:option(TextValue, "customscript2" ,translate("Edit Custom Script2"))
e.description = translate("The execution content of the [Scheduled Customscript2] in the task name")
e.rows = 5
e.default=" "

s=m:section(TypedSection,"stime","")
s.addremove=true
s.anonymous=true
s.template = "cbi/tblsection"

e=s:option(ListValue,"stype",translate("Scheduled Type"))
e:value(1,translate("Scheduled Reboot"))
e:value(2,translate("Scheduled Poweroff"))
e:value(3,translate("Scheduled ReNetwork"))
e:value(4,translate("Scheduled RestartSamba"))
e:value(5,translate("Scheduled Restartwan"))
e:value(6,translate("Scheduled Closewan"))
e:value(7,translate("Scheduled Clearmem"))
e:value(8,translate("Scheduled Sysfree"))
e:value(9,translate("Scheduled DisReconn"))
e:value(10,translate("Scheduled DisRereboot"))
e:value(11,translate("Scheduled Restartmwan3"))
e:value(12,translate("Scheduled Customscript"))
e:value(13,translate("Scheduled Wifiup"))
e:value(14,translate("Scheduled Wifidown"))
e:value(15,translate("Scheduled Customscript2"))
e.default=2

e=s:option(Flag,"enable",translate("Enable"))
e.rmempty = false
e.default=0

e=s:option(ListValue,"ttype",translate("Task Type"))
e:value(0,translate("Scheduled task execution"))
e:value(1,translate("Startup task"))
e.default=0

e=s:option(Value,"delay",translate("Startup delay time"))
e.default=10

e=s:option(Value,"month",translate("Month(0~11)"))
e.rmempty = false
e.default = '*'

week=s:option(Value,"week",translate("Week Day(0~6)"))
week.rmempty = true
week:value('*',translate("Everyday"))
week:value(0,translate("Sunday"))
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week.default='*'

e=s:option(Value,"hour",translate("Hour(0~23)"))
e.rmempty = false
e.default = 0

e=s:option(Value,"minute",translate("Minute(0~59)"))
e.rmempty = false
e.default = 0

m.apply_on_parse = true
m.on_after_apply = function(self,map)
	luci.sys.exec("/etc/init.d/autotimeset start")
end

return m
