local o=require"luci.dispatcher"
local e=require("luci.model.ipkg")
local s=require"nixio.fs"
local e=luci.model.uci.cursor()
local m,s,e

m=Map("autotimeset",translate("Scheduled Setting"),translate("Timing settings include: timing restart, timing shutdown, timing restart network, all functions can be used together."))

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
e.default=2

week=s:option(ListValue,"week",translate("Week Day"))
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

e=s:option(Value,"hour",translate("Hour"))
e.datatype = "range(0,23)"
e.rmempty = false
e.default = 4

e=s:option(Value,"minute",translate("Minute"))
e.datatype = "range(0,59)"
e.rmempty = false
e.default = 0

e=s:option(Flag,"enable",translate("Enable"))
e.rmempty = false
e.default=0

m.apply_on_parse = true
m.on_after_apply = function(self,map)
  io.popen("/etc/init.d/autotimeset start")
end
return m
