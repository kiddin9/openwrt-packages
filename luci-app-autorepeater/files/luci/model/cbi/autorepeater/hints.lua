-- Copyright 2014 Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
-- Licensed to the public under the Apache License 2.0.

local CTRL = require "luci.controller.autorepeater"	-- this application's controller
local DISP = require "luci.dispatcher"
local SYS  = require "luci.sys"
local ATRP = require "luci.tools.autorepeater"		-- autorepeater multiused functions
local NXFS = require "nixio.fs"
local has_miniupnpc, m, info, editconf

local has_miniupnpc = ATRP.has_bin("upnpc")

-- html constants
font_red = [[<font color="red">]]
font_off = [[</font>]]
bold_on  = [[<strong>]]
bold_off = [[</strong>]]

-- cbi-map definition -- #######################################################
m = Map("autorepeater")

m.title = [[<a href="]] .. DISP.build_url("admin", "services", "autorepeater") .. [[">]] ..
		translate("Auto Repeater") .. [[</a>]]

m.description = translate("Auto Repeater helps you turn your router as a repeater, " ..
			"join a wireless station by scan station ssid or bssid first.")


m.redirect = DISP.build_url("admin", "services", "autorepeater")

-- SimpleSection definition -- #################################################
-- show Hints to optimize installation and script usage
ns = m:section( TypedSection, "_dummy",
	translate("Hints"),
	translate("Below a list of configuration tips for your system to run Auto Repeater without limitations") )
ns.addremove = false
ns.anonymous = true
function ns.cfgsections()
	return{"_exrules"}
end

ns:tab("hints", translate("Hints"))
ns:tab("scripts", translate("Parsing"), 
	bold_on .. 
	translate("DO *NOT* Touch any thing here, if you don't know what's going to happen.") .. bold_off
	)

local file_="/usr/lib/autorepeater/scan_mac80211.awk"
editconf=ns:taboption("scripts", TextValue, "Parsing", nil)
editconf.description=translate("Wi-Fi parsing script:") .. font_red
	.. file_ .. font_off
editconf.template="cbi/tvalue"
editconf.rows=15
editconf.wrap="off"
function editconf.cfgvalue()
return NXFS.readfile(file_)or""
end
function editconf.write(selt, section, e)
e=e:gsub("\r\n?","\n")
NXFS.writefile("/tmp/_cfg_",e)
if(luci.sys.call("cmp -s /tmp/_cfg_ " .. file_)==1)then
NXFS.writefile(file_,e)
end
NXFS.remove("/tmp/_cfg_")
end

-- ATRP Service disabled
if not SYS.init.enabled("autorepeater") then
	local info = ns:taboption("hints", DummyValue, "_not_enabled")
	info.titleref = DISP.build_url("admin", "system", "startup")
	info.rawhtml  = true
	info.title = bold_on ..
		translate("Auto Repeater Autostart disabled") .. bold_off
	info.value = translate("Currently Auto Repeater updates are not started at boot or on interface events." .. "<br />" ..
			"This is the default if you run Auto Repeater scripts by yourself (i.e. via cron with force_interval set to '0')" )
			.. "<br /> -"
			.. translate("Flowing the link left to enable Auto Repeater Auto start.")
end

-- "Interface missing instruction"
	local info = ns:taboption("hints", DummyValue, "_interfaces")
	info.titleref = DISP.build_url("admin", "network", "network")
	info.rawhtml  = true
	info.title = bold_on ..
		translate("Wireless WAN Interfaces needed") .. bold_off
	info.value = translate("To enable the station configuration, there must be a enabled sta mode Wi-Fi device. And the device be in external zone to brings the traffic in.")
		.. "<br /> -"
		.. translate("Flowing the link left to change interfaces settings.")
		.. "<br /> -".. font_red
		.. translate("Run \"/etc/init.d/autorepeater start\" once atleast then reboot this device, will brings this settings for you typically")
		.. "<br />"
		.. translate("*DO NOT* delete interfaces by system default network mangement package, it can delete the wireless interface relevant settings permanently") .. font_off

-- "PNP mapping discovery"
	local info = ns:taboption("hints", DummyValue, "_miniupnpc")
	info.titleref = DISP.build_url("admin", "network", "firewall", "rules")
	info.rawhtml  = true
	local info_value = ""
if has_miniupnpc then
	info.title = bold_on ..
		translate("UPnP port mapping to go-through upper router supported") .. bold_off
	info_value = translate("This functions helps to bring specified outer port (setted in mapping list) requests from uper router to this device by installed miniupnpc.")
				.. "<br />"
				.. translate("Routed subnets are invisible from upper devices typically, and miniupnpd will drop UPnP SSDP packages[by 239.255.255.250/UDP] not from the same subnet.")
				.. "<br /> -"
				.. translate("Option one[security risk]: Upper router UPnP SSDP by miniupnpc automatically. Stop miniupnpd to enable SSDP packages in. SSDP package *NEED* Alow *in* by changing firewall forward rules first.[wan/UDP->lan/239.255.255.250/forward] And make sure wan input traffic select *accept* in General/Zones settings.")
				.. "<br /> -"
				.. translate("Flowing the link left to change firewall settings.")
				.. "<br /> -"
				.. translate("Option two[recomend]: Skip upper router UPnP SSDP by providing the XML root description searching urls in global settings.")
				.. "<br /> -"
				.. translate("Not forget to forward the delivered ports from upper router to the specified devices in LAN if you want it.")
				.. "<br /> -"
				.. translate("Further more, try smcroute to relay SSDP packages in such as:/smcroute -d;smcroute -a wlan0 0.0.0.0 239.255.255.250 br-lan;ip mroute/, if you inner devices wanna get the services located in another subnet.")
else
	info.title = bold_on .. font_red ..
		translate("UPnP port mapping through upper router not supported") .. bold_off
	info_value = info_value .. "<br /> -" .. translate("You should install miniupnpc package for PNP port mapping.") .. font_off
end
info.value = info_value


return m
