local m, s, o
local sid = arg[1]

local yeelight_devices = {
	"ColorLEDBulb",
	"DeskLamp",
	"ColorLedStrip",
	"CeilingLamp",
	"WhiteBulb"
}

local airpurifier_devices = {
	"MiAirPurifier",
	"MiAirPurifier2",
	"MiAirPurifierPro",
	"MiAirPurifier2S"
}

local philips_light_devices = {
	"MiPhilipsSmartBulb",
	"MiPhilipsTableLamp2",
	"MiPhilipsCeilingLamp"
}

m = Map("homebridge", translate("Edit Server"))
m.redirect = luci.dispatcher.build_url("admin/services/homebridge/accessories")
m.sid = sid

if m.uci:get("homebridge", sid) ~= "accessory" then
	luci.http.redirect(m.redirect)
	return
end

-- [[ Edit Server ]]--
s = m:section(NamedSection, sid, "accessory")
s.anonymous = true
s.addremove = false

o = s:option(ListValue, "platform_type", translate("Platform Type"))
o:value("homebridge-re-yeelight", translate("Yeelight"))
o:value("homebridge-mi-airpurifier", translate("Mi Airpurifier"))
o:value("homebridge-mi-philips-light", translate("Mi Philips Light"))
o.rmempty = false

o = s:option(ListValue, "yeelight_platform", translate("Yeelight"))
for _, v in ipairs(yeelight_devices) do o:value(v) end
o:depends("platform_type", "homebridge-re-yeelight")

o = s:option(ListValue, "air_platform", translate("Airpurifier"))                 
for _, v in ipairs(airpurifier_devices) do o:value(v) end                     
o:depends("platform_type", "homebridge-mi-airpurifier") 

o = s:option(ListValue, "philips_platform", translate("Philips Light")) 
for _, v in ipairs(philips_light_devices) do o:value(v) end       
o:depends("platform_type", "homebridge-mi-philips-light")

o = s:option(Value, "alias", translate("Alias"))
o.rmempty = false

o = s:option(Value, "ip", translate("IP"))
o.placeholder = "eg: 192.168.1.1"
o.datatype = "ipaddr"
o.rmempty = false

o = s:option(Value, "token","Token") 
o.datatype = "string"
o.rmempty = false

o = s:option(Flag, "updatetimer", translate("Auto Update Device"))
o.default = '1'
o.rmempty = false
o:depends("platform_type", "homebridge-re-yeelight")
o:depends("platform_type", "homebridge-mi-philips-light")

o = s:option(Value, "interval", translate("Interval"))
o.datatype = "uinteger"
o:depends("updatetimer", "1")
o.default = "5"
o.rmempty = false
function o.write(self,section,value)
	if(value~=nil)
	then
        AbstractValue.write(self, section, value)
	else
        AbstractValue.write(self, section, "5")
	end
end

return m





