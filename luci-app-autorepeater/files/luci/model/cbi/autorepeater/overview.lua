-- Copyright 2014 Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
-- Licensed to the public under the Apache License 2.0.

local NXFS = require "nixio.fs"
local CTRL = require "luci.controller.autorepeater"	-- this application's controller
local DISP = require "luci.dispatcher"
local HTTP = require "luci.http"
local SYS  = require "luci.sys"
local ATRP = require "luci.tools.autorepeater"		-- autorepeater multiused functions

local show_hints = not ATRP.has_bin("upnpc")
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

m.on_after_commit = function(self)
	if self.changed then	-- changes ?
		if SYS.init.enabled("autorepeater") then	-- autorepeater service enabled, restart all
			os.execute("/etc/init.d/autorepeater enable && /etc/init.d/autorepeater restart")
		else	-- autorepeater service disabled, send SIGHUP to running
			os.execute("killall -1 autorepeater_updater.sh")
		end
	end
end

-- takeover arguments -- #######################################################
local isec	= arg[1]
local interface = isec
if interface == nil then interface="wan" end

log_dir = m.uci:get(m.config, "global", "log_dir") or "/var/log/autorepeater"

if isec and isec ~= "wan" then
	isec = "-" .. isec
else
	isec = ""
end
m.template = "autorepeater/overview_updater"
m.sfile = log_dir .. "/secs_status"

m:section( SimpleSection,
	translate("Configuration -: ") .. interface,
	translate("Port Mapping and station scanning configurations for interface -: ") .. interface )

if has_miniupnpc then
	local ns = m:section(TypedSection, "pnp-mapping", translate("Port Mapping List"))
	ns.sectionhead = translate("Configuration")
	ns.template = "cbi/tblsection"
	ns.addremove = true
	ns.extedit = DISP.build_url("admin", "services", "autorepeater", "autorepeater-pnpmaps", "%s")
	function ns.create(self, name)
		AbstractSection.create(self, name)
		HTTP.redirect( self.extedit:format(name) )
	end
	ns:option(DummyValue,"proto",translate("Protocol"))
	ns:option(DummyValue,"port",translate("External port"))
	ns:option(DummyValue,"port",translate("Local Port"))
	des=ns:option(DummyValue,"_LastMap",translate("Description/LastMapped/Failed"))
	des.template = "autorepeater/overview_doubleline"
	function des.set_one(self, section)
		local desstr = self.map:get(section, "des") or ""
		if desstr ~= "" then
			return desstr
		else
			return [[<em>]] .. translate("-notset-") .. [[</em>]]
		end
	end

	function des.set_two(self, section)
		return translate("Unknown")
	end

	local e=ns:option(Flag,"enabled",translate("Enabled"))
	e.template = "autorepeater/overview_enabled"
	e.rmempty = false
	function e.parse(self, section)
		ATRP.flag_parse(self, section)
	end
end

-- TableSection definition -- ##################################################
ts = m:section( TypedSection, "wifi-station" .. isec,
	translate("Wi-Fi Scanning List"),
	translate("Below is a list of station scanning configurations and their broadcasting state."
		.. [[<br /><strong>]] ..
		"Will trying to associate the *MATCHING* stations by signal strength or saved order. (change by golbal settings)"
		.. [[<br /></strong>]]
		) )
ts.sectionhead = translate("Configuration")
ts.template = "cbi/tblsection"
ts.addremove = true
ts.sortable=true
ts.extedit = DISP.build_url("admin", "services", "autorepeater", "autorepeater-stations", "%s")
function ts.create(self, name)
	AbstractSection.create(self, name)
	HTTP.redirect( self.extedit:format(name) )
end

devt = ts:option( DummyValue, "is_mac",
	translate("Scanning Type") )
devt.rmempty = false
function devt.cfgvalue(self, section)
	local devstr = self.map:get(section, "is_mac") or ""
	if devstr == "1" then return translate("BSSID")
	else return translate("SSID")
	end
end

-- Scanstr and RealBSSID -- #################################################
snr = ts:option(DummyValue, "_LastSignal",
	translate("Matching/RealBSSID") .. "<br />" .. translate("Signal Strength") )
snr.template = "autorepeater/overview_doubleline"
function snr.set_one(self, section)
	local devstr = self.map:get(section, "dev_str") or ""
	if devstr ~= "" then
		return devstr
	else
		return [[<em>]] .. translate("config error") .. [[</em>]]
	end
end

function snr.set_two(self, section)
	return translate("unknown")
end

-- Encryption and Cipher -- #################################################
enc = ts:option(DummyValue, "_Realcipher",
	translate("Key/Encryption") .. "<br />" .. translate("Real Security") )
enc.template = "autorepeater/overview_doubleline"
function enc.set_one(self, section)
	local key = self.map:get(section, "key") or "auto"
	if key ~= "" then
		return key
	else
		return [[<em>]] .. translate("config error") .. [[</em>]]
	end
end
function enc.set_two(self, section)
	return translate("Unknown")
end

-- enabled
ena = ts:option( Flag, "enabled",
	translate("Enabled"))
ena.template = "autorepeater/overview_enabled"
ena.rmempty = false
function ena.parse(self, section)
	ATRP.flag_parse(self, section)
end

-- show PID and next update
upd = ts:option( DummyValue, "_LastConn",
	translate("Fail/Success")
	.. "<br />"
	.. translate("Last Status"))
upd.template = "autorepeater/overview_doubleline"
function upd.set_one(self, section)	-- fill Last Fail
	return translate("unknown")
end
function upd.set_two(self, section)	-- fill Next Success
	return translate("unknown")
end

return m
