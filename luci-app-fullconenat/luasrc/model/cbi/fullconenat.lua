#-- Copyright (C) 2018 dz <dingzhong110@gmail.com>

local fwm = require "luci.model.firewall".init()
local def = fwm:get_defaults()
local zn = fwm:get_zone("wan")
local m, s, o, fw3_buildin, has_module, status, des

local function testcmd (cmd)
  return luci.sys.call(cmd) == 0
end

has_module = testcmd("modprobe -q xt_FULLCONENAT")
fw3_buildin = testcmd("strings `which fw3` | grep -q fullcone")

m = Map("fullconenat", translate("Full cone NAT"),
	translate("FullConeNat."))
status="<strong><font color=\"red\">Not supported, Kernel module needed: xt_FULLCONENAT</font></strong>"
if has_module then
if testcmd("iptables -t nat -L -n --line-numbers | grep FULLCONENAT >/dev/null") then
	status="<strong><font color=\"green\">Running</font></strong>"
else
	status="<strong><font color=\"red\">Not Running</font></strong>"
end
end

m = Map("fullconenat", translate("FullConeNat"), "%s - %s" %{translate("FULLCONENAT"), translate(status)})

des = fw3_buildin and "Build-in mode, set the `fullcone` option to firewall configure either." or "Manual mode, write to the firewall custom rules settings only."
s = m:section(TypedSection, "fullconenat", translate("Settings"), translate(des))
s.anonymous = true

o = s:option(ListValue, "mode", translate("Register modes"), translate("<strong><font color=\"red\">Warning!!! There is security risk if enabled.</font></strong>"))
o.widget  = "radio"
o.orientation = "horizontal"
o.default = "disable"
o.rmempty = false
o:value("disable", translate("Disable"))
o:value("ips", translate("IP Address Only"))
o:value("all", translate("ALL Enabled"))
o.cfgvalue = function (self, sec)
  local ret = "disable"
  if fw3_buildin and def:get("fullcone") == "1" then
    ret = "all"
  else
    ret = self.map:get(sec, self.option)
  end
  return has_module and ret or "disable"
end
o.write = function (self, sec, val)
  val = has_module and val or "disable"
  if fw3_buildin then
    def:set("fullcone", val == "all" and 1 or 0)
    zn:set("fullcone", val == "all" and 1 or 0)
  end
  fwm.commit()
  return self.map:set(sec, self.option, val)
end

o = s:option(Value, "fullconenat_ip", translate("FullConeNat IP"), translate("Enable FullConeNat for specified IP Address.") .. "<br />" .. (fw3_buildin and translate("Manual mode, write to the firewall custom rules settings only.") or ""))
o.placeholder="192.168.1.100,192.168.1.101,192.168.1.102"
o.rempty = true
o.optional = false
o:depends("mode", "ips")

return m
