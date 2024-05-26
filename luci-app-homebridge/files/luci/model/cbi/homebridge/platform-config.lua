local m, s, o
local sid = arg[1]

local yeelight_devices = {
	"ColorLEDBulb",
	"DeskLamp",
	"ColorLedStrip",
	"CeilingLamp",
	"WhiteBulb"
}

local philips_light_devices = {
	"MiPhilipsSmartBulb",
	"MiPhilipsTableLamp2",
	"MiPhilipsCeilingLamp"
}

local mi_plug_devices = {
	"MiPlugBase",
	"MiPlugBaseWithUSB",
	"MiIntelligencePinboard",
	"MiQingPinboard",
	"MiQingPinboardWithUSB"
}

local vacuum_devices = {
	"MiRobotVacuum",
	"MiRobotVacuum2"
}

m = Map("homebridge", translate("Edit Server"))
m.redirect = luci.dispatcher.build_url("admin/services/homebridge/platforms")
m.sid = sid

if m.uci:get("homebridge", sid) ~= "platform" then
	luci.http.redirect(m.redirect)
	return
end

-- [[ Edit Platform ]]--
s = m:section(NamedSection, sid, "platform")
s.anonymous = true
s.addremove = false

o = s:option(Flag, "is_independent", translate("Independent"))
o.rmempty = false

o = s:option(Value, "name", translate("Homebridge Name"))    
o.default = "homebridge"                                 
o:depends("is_independent", "1")
                                                         
o = s:option(Value, "username", translate("Mac Address"))
o.datatype = "macaddr"                                   
o.default = "CC:22:3D:E3:CE:30"                          
o:depends("is_independent", "1")
                                                         
o = s:option(Value, "port", translate("Port"))
o.datatype = "port"                           
o.default = "51826"                           
o:depends("is_independent", "1")
                                              
o = s:option(Value, "pin", "Pin")
o.datatype = "string"            
o.default = "123-45-789"         
o:depends("is_independent", "1")

o = s:option(ListValue, "platform_type", translate("Platform Type"))
o:value("ReYeelightPlatform", translate("Yeelight"))
o:value("MiPhilipsLightPlatform", translate("Mi Philips Light"))
o:value("MiOutletPlatform", translate("Mi Plug"))
o:value("MiRobotVacuumPlatform", translate("Mi Vacuum"))
o.rmempty = false

o = s:option(ListValue, "platform_yeelight", translate("Yeelight"))
for _, v in ipairs(yeelight_devices) do o:value(v) end
o:depends("platform_type", "ReYeelightPlatform")

o = s:option(ListValue, "platform_philips_light", translate("Philips Light")) 
for _, v in ipairs(philips_light_devices) do o:value(v) end       
o:depends("platform_type", "MiPhilipsLightPlatform")

o = s:option(ListValue, "platform_mi_plug", translate("Mi Plug"))
for _, v in ipairs(mi_plug_devices) do o:value(v) end
o:depends("platform_type", "MiOutletPlatform")

o = s:option(ListValue, "platform_vacuum", translate("Vacuum"))
for _, v in ipairs(vacuum_devices) do o:value(v) end
o:depends("platform_type", "MiRobotVacuumPlatform")

o = s:option(Value, "alias", translate("Alias"))
o.rmempty = false

o = s:option(Value, "ip", translate("IP"))
o.placeholder = "eg: 192.168.1.1"
o.datatype = "ipaddr"
o.rmempty = false

o = s:option(Value, "token","Token") 
o.datatype = "string"
o.rmempty = false

-- [ yeelight config ] --
o = s:option(Flag, "updatetimer", translate("Auto Update Device"))
o.default = '1'
o:depends("platform_type", "ReYeelightPlatform")
o:depends("platform_philips_light", "MiPhilipsCeilingLamp")
o.rmempty = false

o = s:option(Value, "interval", translate("Interval"))
o.datatype = "uinteger"
o:depends("updatetimer", "1")
o.default = "5"
-- [ yeelight config ] --

-- [Philips Light Config] --
o = s:option(Value, "main_light_name", translate("Main Light Name"))
o:depends("platform_philips_light", "MiPhilipsTableLamp2")
o.default = "main light"
o.datatype = "string"

o = s:option(Flag, "second_light_disable", translate("Disable Second Light"))
o.default = false
o:depends("platform_philips_light", "MiPhilipsTableLamp2")
o.rmempty = false

o = s:option(Value, "second_light_name", translate("Second Light Name"))
o:depends("platform_philips_light", "MiPhilipsTableLamp2")
o.default = "second light"
o.datatype = "string"

o = s:option(Flag, "eyecare_switch_disable", translate("Disable Eyecare Model"))
o:depends("platform_philips_light", "MiPhilipsTableLamp2")
o.default = "0"
o.rmempty = false

o = s:option(Value, "eyecare_switch_name", translate("Eyecare Model Name"))
o:depends("platform_philips_light", "MiPhilipsTableLamp2")
o.default = "eyecare model"
-- [Philips Light Config] --

-- [ Outlet Config ] --
o = s:option(Flag, "outlet_disable", translate("Disable Plug"))
o.default = "0"
o.rmempty = false
o:depends("platform_type", "MiOutletPlatform")

o = s:option(Flag, "temperature_disable", translate("Disable Temperature"))
o.default = "0"
o:depends("platform_type", "MiOutletPlatform")
o.rmempty = false

o = s:option(Value, "temperature_name", translate("Temperature Name"))
o:depends("platform_type", "MiOutletPlatform")
o.datatype = "string"
o.default = "temperature"

o = s:option(Flag, "switch_LED_disable", translate("Disable LED"))
o:depends("platform_mi_plug", "MiPlugBase")
o:depends("platform_mi_plug", "MiIntelligencePinboard")
o.default = "0"
o.rmempty = false

o = s:option(Value, "switch_LED_name", translate("LED Name"))
o:depends("platform_mi_plug", "MiPlugBase")                       
o:depends("platform_mi_plug", "MiIntelligencePinboard")
o.datatype = "string"
o.default = "LED"

o = s:option(Flag, "switch_USB_disable", translate("Disable USB"))
o.default = "0"
o:depends("platform_mi_plug", "MiPlugBaseWithUSB")
o.rmempty = false

o = s:option(Value, "switch_USB_name", translate("USB Name"))
o.datatype = "string"
o:depends("platform_mi_plug", "MiPlugBaseWithUSB")
o.default = "USB"
-- [ Outlet Config ] --


return m





