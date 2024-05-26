local NX   = require "nixio"
--local NXFS = require "nixio.fs"
--local SYS  = require "luci.sys"
--local UTIL = require "luci.util"
local DISP = require "luci.dispatcher"
--local WADM = require "luci.tools.webadmin"
--local DTYP = require "luci.cbi.datatypes"
local ATRP = require "luci.tools.autorepeater"		-- autorepeater multiused functions

-- takeover arguments -- #######################################################
local section = arg[1]or""
local isec = arg[2]or""
if isec == "wan" then
	isec = ""
end
if isec ~="" then
	isec = "-" .. isec
end
-- html constants -- ###########################################################
local font_red	= "<font color='red'>"
local font_off	= "</font>"
local bold_on	= "<strong>"
local bold_off	= "</strong>"

-- cbi-map definition -- #######################################################
m = Map("autorepeater")

m.title = [[<a href="]] .. DISP.build_url("admin", "services", "autorepeater") .. [[">]] ..
		translate("Auto Repeater") .. [[</a>]]

m.description = translate("Auto Repeater helps you turn your router as a repeater, " ..
			"join a wireless station by scan station ssid or bssid first.")

m.redirect = DISP.build_url("admin", "services", "autorepeater", "autorepeater-overview", isec)

m.on_after_commit = function(self)
	if self.changed then	-- changes ?
		local pid = ATRP.get_pid(section)
		if pid > 0 then	-- running ?
			local tmp = NX.kill(pid, 1)	-- send SIGHUP
		end
	end
end

-- read application settings -- ################################################
-- date format; if not set use ISO format
date_format = m.uci:get(m.config, "global", "date_format") or "%F %R"
-- log directory
log_dir = m.uci:get(m.config, "global", "log_dir") or "/var/log/autorepeater"

-- cbi-section definition -- ###################################################
ns = m:section( NamedSection, section, "pnp-mapping",
	translate("Details for") .. ([[: <strong>%s</strong>]] % section),
	translate("Allows SSDP service port:[TCP/1900 commonly] in byc change firewall settings, to perform PNP devices discovery correctly.") )
ns.instance = section	-- arg [1]

-- enabled  -- #################################################################
--en = ATRP.opt_enabled(ns, Button, "enabled")
en = ns:option(Flag, "enabled", translate("Enabled"))
en.orientation	= "horizontal"
en.rmempty	= true
en.default	= "0"
function en.parse(self, section)
	ATRP.flag_parse(self, section)
end

pr = ns:option(ListValue, "proto",
	translate("Protocol") )
pr.default = "TCP"
pr:value("TCP","TCP")
pr:value("UDP","UDP")
pr.rmempty = false

rp = ns:option(Value, "port",
	translate("External port"),
	translate("Trying to map this port number on upper router PNP") )
rp.default	= "80"
rp.datatype = "port"
rp.rmempty = false

des = ns:option(Value, "des",
	translate("Description for port mapping"))
des.default	= "PortMap (Added by CP2PEngine) ["
des.placeholder = "PortMap (Added by CP2PEngine) ["
des.rmempty = false

des = ns:option(Value, "max_failed",
	translate("Max failed times for trying"))
des.default	= 3
des.datatype = "uinteger"
des.rmempty = true

return m
