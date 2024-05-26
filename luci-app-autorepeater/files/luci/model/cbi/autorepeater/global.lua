-- 	-- -- Copyright 2014 Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
-- Licensed to the public under the Apache License 2.0.

local NX   = require "nixio"
local NXFS = require "nixio.fs"
local DISP = require "luci.dispatcher"
local SYS  = require "luci.sys"
local HTTP = require "luci.http"
local WADM = require "luci.tools.webadmin"
local DTYP = require "luci.cbi.datatypes"
local ATRP = require "luci.tools.autorepeater"		-- autorepeater multiused functions
local UCI = luci.model.uci.cursor()
local util  = require "luci.util"

local ilist = {}
ilist=UCI:get_list("autorepeater", "global", "interface")
local section = "global"
local ezl = {}
local ntm = require "luci.model.network"
local fwm = require "luci.model.firewall".init()
	ntm.init(UCI)
	for _, inet in ipairs(ntm:get_networks()) do
		local tiface = inet:get_interface()
		local z = fwm:get_zone_by_network(inet:name())
		if z ~= nil and tiface ~= nil and net:name() ~= "loopback" and tiface:type() ~= "ethernet" and z:name() ~= "lan" then
			ezl[#ezl+1] = inet:name()
		end
	end
-- interface list checking --
local vintfs = {}
for _, s in ipairs(ilist) do
	if util.contains(ezl, s) then
		vintfs[#vintfs+1] = {key=s, val=s}
	else
		vintfs[#vintfs+1]= {key=s, val="--" .. s .. translate("<not-valid>")}
	end
end
-- append missing interface
for _, s in ipairs(ezl) do
	local isin=1
	for _, k in ipairs(vintfs) do
		if k.key == s then isin=0 end
	end
	if isin == 1 then vintfs[#vintfs+1] = {key=s, val=s} end
end

-- check supported options -- ##################################################
local has_miniupnpc = ATRP.has_bin("upnpc")
-- cat /sys/kernel/debug/gpio | grep button
local btcmd="ls -1 /etc/rc.button/ | egrep -v -e failsafe -e power -e [^.]{8,}"
local shellpipe = io.popen(btcmd,"r")

-- html constants -- ###########################################################
local font_red	= "<font color='red'>"
local font_off	= "</font>"
local bold_on	= "<strong>"
local bold_off	= "</strong>"

-- error text constants -- #####################################################
function err_timer(self)
	return translate("Timer Settings") .. " - " .. self.title .. ": "
end

-- cbi-map definition -- #######################################################
local m = Map("autorepeater")

m.title = [[<a href="]] .. DISP.build_url("admin", "services", "autorepeater") .. [[">]] ..
		translate("Auto Repeater") .. [[</a>]]

m.description = translate("Auto Repeater helps you turn your router as a repeater, " ..
			"join a wireless station by scan station ssid or bssid first.")

m.redirect = DISP.build_url("admin", "services", "autorepeater")

function m.commit_handler(self)
	if self.changed then	-- changes ?
		os.execute("/etc/init.d/autorepeater reload &")	-- reload configuration
	end
end

-- read application settings -- ################################################
-- date format; if not set use ISO format
date_format = m.uci:get(m.config, "global", "date_format") or "%F %R"
-- log directory
log_dir = m.uci:get(m.config, "global", "log_dir") or "/var/log/autorepeater"

-- cbi-section definition -- ###################################################
local ns = m:section( NamedSection, "global","autorepeater",
	translate("Global Settings"),
	translate("Configure here the details for station searching services including miniupnpc application.") 
	.. [[<br /><strong>]]
	.. translate("It is *NOT* recommended for casual users to change settings on this page.")
	.. [[</strong><br />]]
	)

-- section might not exist
function ns.cfgvalue(self, section)
	if not self.map:get(section) then
	self.map:set(section, nil, self.sectiontype)
	end
	return self.map:get(section)
end

ns:tab("Basic", translate("Basic"))
ns:tab("assoc", translate("Associating"))
ns:tab("timer", translate("Timing"))
ns:tab("PortMapping", translate("Mapping"))
ns:tab("Logging", translate("Logging"))

-- use_curl  -- ################################################################
if (SYS.call([[ grep -i "\+ssl" /usr/bin/wget >/dev/null 2>&1 ]]) == 0) 
and NXFS.access("/usr/bin/curl") then
	local pc	= ns:taboption("Basic", Flag, "use_curl")
	pc.title	= translate("Use cURL")
	pc.description	= translate("If both cURL and GNU Wget are installed, Wget is used by default.")
		.. [[<br />]]
		.. translate("To use cURL activate this option.")
	pc.orientation	= "horizontal"
	pc.rmempty	= true
	pc.default	= "0"
	function pc.parse(self, section)
		ATRP.flag_parse(self, section)
	end
	function pc.validate(self, value)
		if value == self.default then
			return "" -- default = empty
		end
		return value
	end
end

local pc	= ns:taboption("Basic", Flag, "mwifi_enabled")
pc.title	= translate("Global Enabled")
pc.description	= translate("Turn On/Off Wi-Fi station searching globally.")
pc.orientation	= "horizontal"
pc.rmempty	= false
pc.default	= "0"
function pc.parse(self, section)
	ATRP.flag_parse(self, section)
end
function err_tab_timer(self)
	return translate("Timer Settings") .. " - " .. self.title .. ": "
end

local ins = ns:taboption("Basic", DynamicList, "interface", translate("Interface"))
ins.template = "autorepeater/dynamiclist"
for _, s in ipairs(vintfs) do ins:value(s.key, s.val) end
--for _, s in ipairs(ezl) do ins:value(s, s) end
ins.default = "wan"
ins.rmempty = false

-- date_format  -- #############################################################
local df	= ns:taboption("Basic", Value, "date_format")
df.title	= translate("Date format")
df.description	= [[<a href="http://www.cplusplus.com/reference/ctime/strftime/" target="_blank">]]
		.. translate("For supported codes look here") 
		.. [[</a>]]
df.template	= "autorepeater/global_value"
df.rmempty	= true
df.default	= "%F %R"
df.date_string	= ""
function df.cfgvalue(self, section)
	local value = AbstractValue.cfgvalue(self, section) or self.default
	local epoch = os.time()
	self.date_string = ATRP.epoch2date(epoch, value)
	return value
end

local pc	= ns:taboption("Basic", ListValue, "ethernet_bt")
pc.title	= translate("AP Toggle Button")
pc.description	= translate("Specify a button to toggle Wi-Fi AP permanently, trigger by press the button shortly.")
	..[[<br />]] ..
	translate("Dangerous! Gona to rewrite hardware button functions, you need to fix that back manually.")
	.. [[<br /><strong>]] ..
	translate("Set this value not *None* to switch Wi-Fi AP On/Off by specified button.")
	.. [[--<a href='https://wiki.openwrt.org/doc/howto/hardware.button#procd_buttons'>]] ..
	translate("buttons using procd")
	.. [[</a>--</strong><br />]] ..
	translate("The power led will blinking as entering failsafe mode if AP Toggle Off by switch.")
pc.template = "autorepeater/global_buttons"
pc.rmempty	= true
pc.default	= ""
pc.alias_function = ""
pc:value("", translate("None"))
for _ls in shellpipe:lines() do
	pc:value(_ls, translate(_ls))
end
function pc.cfgvalue(self, section)
	local value = AbstractValue.cfgvalue(self, section) or self.default
	local func = translate("- skiped -")
	if value then
		func = translate("- notset -")
		local type = UCI:get("system", value, "button") or ""
		if type then
			func = UCI:get("system", value , "handler") or translate("-no handler-")
		end
		UCI:unload("system")
	end
	self.alias_function = translate("Current function") .. ": <font color='red'><i>" .. func .. "</i></font>"
	return value
end
function pc.write(self, section, value)
	if value then
		UCI:set("system", value, "button")
		UCI:set("system", value, "button", value)
		UCI:set("system", value, "action", "released")
		UCI:set("system", value, "min", "0")
		UCI:set("system", value, "handler", "logger rfkill trigger by autorepeater ; /usr/lib/autorepeater/rfkill.sh ;")
		UCI:set("system", value, "autorepeater", "fixme")
		UCI:commit("system")
		UCI:unload("system")
	end
	return self.map:set(section, self.option, value)
end
function pc.remove(self, section, value)
	UCI:delete_all("system", "button",
		function(s) return (s.autorepeater == "fixme") end)
	UCI:commit("system")
	UCI:unload("system")
	return self.map:del(section, self.option)
end

-- scanpercent  -- ###############################################################
local ll	= ns:taboption("assoc", Value, "scanpercent")
ll.title	= translate("Scanning Strength")
ll.description	= translate("Minimum signal strength to searching")
ll.rmempty	= true
ll.default	= "15"
function ll.validate(self, value)
	local n = tonumber(value)
	if not n then
		return nil, self.title .. ": " .. translate("Scannign strength error")
	end
	return value
end

-- minipercent  -- ###############################################################
local ll	= ns:taboption("assoc", Value, "minipercent")
ll.title	= translate("Assocication Strength")
ll.description	= translate("Minimum signal strength to association")
ll.rmempty	= true
ll.default	= "50"
function ll.validate(self, value)
	local n = tonumber(value)
	if not n or math.floor(n) ~= n or n < 30 then
		return nil, self.title .. ": " .. translate("Minimum value '30'")
	end
	return value
end

-- asso_order  -- ###############################################################
local ll	= ns:taboption("assoc", ListValue, "associate_order", translate("Assocication Trying Order"))
ll.widget  = "radio"
ll.orientation = "horizontal"
--ll.description	= translate("By saved order or strength")
ll:value("0", translate("By Signal Strength"))
ll:value("1", translate("By Saved"))
ll.rmempty	= true
ll.default	= "0"

-- a_band_first  -- ###############################################################
local ll	= ns:taboption("assoc", ListValue, "a_band_first", translate("Take \"A\" Band First"))
ll.widget  = "radio"
ll.orientation = "horizontal"
--ll.description	= translate("Trying to assocate \"A\" band station in the first place")
ll:value("0", translate("No"))
ll:value("1", translate("Yes"))
ll:depends("associate_order", "0")
ll.rmempty	= true
ll.default	= "1"

-- ping_host  -- #################################################################
local ld	= ns:taboption("assoc", Value, "ping_host")
ld.title	= translate("Alive Checking")
ld.description	= translate("Domain to PING internet connecting status after station associated," .. [[<br />]] ..
		"to confirm it is not needed to try next station." .. [[<br />]] ..
		"use local IPv4-Address to disable it's routing, such as: 192.168.1.1")
ld.rmempty	= false
ld.default	= "www.baidu.com"

-- TAB: Timer  #####################################################################################
-- dhcp_timeout  -- ###############################################################
local ll	= ns:taboption("timer", Value, "dhcp_timeout")
ll.title	= translate("Timeout")
ll.description	= translate("Number of maxmum seconds of wating station's DHCP to lease a IP")
ll.rmempty	= true
ll.default	= "20"
function ll.validate(self, value)
	local n = tonumber(value)
	if not n or math.floor(n) ~= n or n < 20 then
		return nil, self.title .. ": " .. translate("minimum value '20'")
	end
	return value
end

-- check_interval -- ###########################################################
ci = ns:taboption("timer", Value, "check_interval",
	translate("Check Interval") )
ci.template = "autorepeater/detail_value"
ci.default  = 5
ci.rmempty = false	-- validate ourselves for translatable error messages
function ci.validate(self, value)
	if not DTYP.uinteger(value)
	or tonumber(value) < 1 then
		return nil, err_tab_timer(self) .. translate("minimum value 5 minutes == 300 seconds")
	end

	local secs = ATRP.calc_seconds(value, cu:formvalue(section))
	if secs >= 300 then
		return value
	else
		return nil, err_tab_timer(self) .. translate("minimum value 5 minutes == 300 seconds")
	end
end
function ci.write(self, section, value)
	-- simulate rmempty=true remove default
	local secs = ATRP.calc_seconds(value, cu:formvalue(section))
	if secs ~= 300 then	--default 10 minutes
		return self.map:set(section, self.option, value)
	else
		self.map:del(section, "check_unit")
		return self.map:del(section, self.option)
	end
end

-- check_unit -- ###############################################################
cu = ns:taboption("timer", ListValue, "check_unit", "not displayed, but needed otherwise error",
	translate("Interval to check for internate connection" .. "<br />" ..
		"Values below 5 minutes == 300 seconds are not supported") )
cu.template = "autorepeater/detail_lvalue"
cu.default  = "minutes"
cu.rmempty  = false	-- want to control write process
cu:value("seconds", translate("seconds"))
cu:value("minutes", translate("minutes"))
cu:value("hours", translate("hours"))
--cu:value("days", translate("days"))
function cu.write(self, section, value)
	-- simulate rmempty=true remove default
	local secs = ATRP.calc_seconds(ci:formvalue(section), value)
	if secs ~= 300 then	--default 10 minutes
		return self.map:set(section, self.option, value)
	else
		return true
	end
end

-- force_interval (modified) -- ################################################
fi = ns:taboption("timer", Value, "force_interval",
	translate("Force Interval") )
fi.template = "autorepeater/detail_value"
fi.default  = 12 	-- see autorepeater_updater.sh script
fi.datatype = "uinteger"
fi.rmempty = false	-- validate ourselves for translatable error messages
function fi.validate(self, value)
	if not DTYP.uinteger(value)
	or tonumber(value) < 0 then
		return nil, err_tab_timer(self) .. translate("minimum value '0'")
	end

	local force_s = ATRP.calc_seconds(value, fu:formvalue(section))
	if force_s == 0 then
		return value
	end

	local ci_value = ci:formvalue(section)
	if not DTYP.uinteger(ci_value) then
		return ""	-- ignore because error in check_interval above
	end

	local check_s = ATRP.calc_seconds(ci_value, cu:formvalue(section))
	if force_s >= check_s then
		return value
	end

	return nil, err_tab_timer(self) .. translate("must be greater or equal 'Check Interval'")
end
function fi.write(self, section, value)
	-- simulate rmempty=true remove default
	local secs = ATRP.calc_seconds(value, fu:formvalue(section))
	if secs ~= 43200 then	--default 12 hours == 0.5 days
		return self.map:set(section, self.option, value)
	else
		self.map:del(section, "force_unit")
		return self.map:del(section, self.option)
	end
end

-- force_unit -- ###############################################################
fu = ns:taboption("timer", ListValue, "force_unit", "not displayed, but needed otherwise error",
	translate("Interval to force stations broadcast checking"
		.. [[<br />]] ..
		"Setting this parameter to 0 will force the script to only run once"
		.. [[<br /><strong>]] ..
		"*NOT* less than 3 minutes(station monitor routing), or you can loss connect via Wi-Fi AP if there are no available station exists" ..
		[[<br /></strong>]] .. "Values lower 'Check Interval' except '0' are not supported"
		) )
fu.template = "autorepeater/detail_lvalue"
fu.default  = "hours"
fu.rmempty  = false	-- want to control write process
--fu:value("seconds", translate("seconds"))
fu:value("minutes", translate("minutes"))
fu:value("hours", translate("hours"))
fu:value("days", translate("days"))
function fu.write(self, section, value)
	-- simulate rmempty=true remove default
	local secs = ATRP.calc_seconds(fi:formvalue(section), value)
	if secs ~= 43200 and secs ~= 0 then	--default 12 hours == 0.5 days
		return self.map:set(section, self.option, value)
	else
		return true
	end
end

-- retry_interval -- ###########################################################
ri = ns:taboption("timer", Value, "retry_interval",
	translate("Error Retry Interval") )
ri.template = "autorepeater/detail_value"
ri.default  = 30
ri.rmempty  = false	-- validate ourselves for translatable error messages
function ri.validate(self, value)
	if not DTYP.uinteger(value)
	or tonumber(value) < 1 then
		return nil, err_tab_timer(self) .. translate("minimum value '1'")
	else
		return value
	end
end
function ri.write(self, section, value)
	-- simulate rmempty=true remove default
	local secs = ATRP.calc_seconds(value, ru:formvalue(section))
	if secs ~= 30 then	--default 30seconds
		return self.map:set(section, self.option, value)
	else
		self.map:del(section, "retry_unit")
		return self.map:del(section, self.option)
	end
end

-- retry_unit -- ###############################################################
ru = ns:taboption("timer", ListValue, "retry_unit", "not displayed, but needed otherwise error",
	translate("The station association will retry once after the DHCP timeout") )
ru.template = "autorepeater/detail_lvalue"
ru.default  = "seconds"
ru.rmempty  = false	-- want to control write process
ru:value("seconds", translate("seconds"))
ru:value("minutes", translate("minutes"))
--ru:value("hours", translate("hours"))
--ru:value("days", translate("days"))
function ru.write(self, section, value)
	-- simulate rmempty=true remove default
	local secs = ATRP.calc_seconds(ri:formvalue(section), value)
	if secs ~= 30 then	--default 30seconds
		return self.map:set(section, self.option, value)
	else
		return true -- will be deleted by retry_interval
	end
end

-- use_syslog -- ###############################################################
slog = ns:taboption("Logging", ListValue, "use_syslog",
	translate("Log to syslog"),
	translate("Writes log messages to syslog. Critical Errors will always be written to syslog.") )
slog.default = "2"
slog:value("0", translate("No logging"))
slog:value("1", translate("Info"))
slog:value("2", translate("Notice"))
slog:value("3", translate("Warning"))
slog:value("4", translate("Error"))

-- use_logfile (NEW) -- ########################################################
logf = ns:taboption("Logging", Flag, "use_logfile",
	translate("Log to file"),
	translate("Writes detailed messages to log file. File will be truncated automatically.")
	)
logf.orientation = "horizontal"
logf.rmempty = false	-- we want to save in /etc/config/autorepeater file on "0" because
logf.default = "1"	-- if not defined write to log by default
function logf.parse(self, section)
	ATRP.flag_parse(self, section)
end

-- run_dir  -- #################################################################
local rd	= ns:taboption("Logging", Value, "run_dir")
rd.title	= translate("Status directory")
rd.description	= translate("Directory contains PID and other status information for searching history.")
rd.rmempty	= true
rd.default	= "/var/run/autorepeater"

-- log_dir  -- #################################################################
local ld	= ns:taboption("Logging", Value, "log_dir")
ld.title	= translate("Log directory")
ld.description	= translate("Directory contains Log files for searching history")
ld.rmempty	= true
ld.default	= "/var/log/autorepeater"

-- html_page  -- #################################################################
local ld	= ns:taboption("Logging", Value, "html_page")
ld.title	= translate("Html logfile")
ld.description	= translate("Out of login connecting status page.")
ld.default	= "autorepeater.html"
ld.template	= "autorepeater/global_link"
ld.link_string = ""
ld.rmempty	= true
function ld.cfgvalue(self, section)
	local value = AbstractValue.cfgvalue(self, section) or self.default
	self.link_string = translate("Current setting") .. ": <strong><a href='/" .. value .. "'>" .. translate("Review") .. "</a></strong>"
	return value
end

-- log_lines  -- ###############################################################
local ll	= ns:taboption("Logging", Value, "log_lines")
ll.title	= translate("Log length")
ll.description	= translate("Number of last lines stored in log files")
ll.rmempty	= true
ll.default	= "250"
function ll.validate(self, value)
	local n = tonumber(value)
	if not n or math.floor(n) ~= n or n < 1 then
		return nil, self.title .. ": " .. translate("minimum value '1'")
	end
	return value
end

local pc	= ns:taboption("PortMapping", Flag, "upnpc_enabled")
pc.title	= translate("Enabled")
pc.description	= translate("To use miniupnpc port mapping activate this option.")
pc.orientation	= "horizontal"
pc.rmempty	= true
pc.default	= "0"
function pc.parse(self, section)
	ATRP.flag_parse(self, section)
end

local ll	= ns:taboption("PortMapping", Value, "upnpc_failsafe")
ll.title	= translate("Failsafe")
ll.description	= translate("Number of fails to stop port map trying")
ll.rmempty	= true
ll.default	= "3"
function ll.validate(self, value)
	local n = tonumber(value)
	if not n or math.floor(n) ~= n or n < 1 then
		return nil, self.title .. ": " .. translate("minimum value '1'")
	end
	return value
end

local pc	= ns:taboption("PortMapping", Flag, "upnpc_forceroot")
pc.title	= translate("Force XML root url")
pc.description	= translate("bypass miniupnpc UPnP device discovery activate this option.")
pc.orientation	= "horizontal"
pc.rmempty	= true
pc.default	= "0"
function pc.parse(self, section)
	ATRP.flag_parse(self, section)
end

ur = ns:taboption("PortMapping", DynamicList, "root_url", translate("XML root description url"),
	translate("bypass discovery process by providing the XML root description url, after no available UPnP discovered."))
ur.optional = true
--ur:depends("upnpc_enabled", "1")
ur.placeholder = "http://[ROUTERIP]:1900/igd.xml"

-------------
local apply = luci.http.formvalue("cbi.apply")
if apply then
	os.execute("/etc/init.d/autorepeater restart >/dev/null 2>&1 &")
end
--------------

return m
