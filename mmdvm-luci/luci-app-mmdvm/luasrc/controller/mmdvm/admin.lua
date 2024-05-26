-- Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

module("luci.controller.mmdvm.admin", package.seeall)

local sys   = require("luci.sys")
local util  = require("luci.util")
local http  = require("luci.http")
local i18n  = require("luci.i18n")
local json  = require("luci.jsonc")
local uci   = require("luci.model.uci").cursor()

function index()
	if not nixio.fs.access("/etc/MMDVM.ini") then
		return
	end
	entry({"admin", "mmdvm"}, firstchild(), _("Radio"), 30).dependent = false
	entry({"admin", "mmdvm", "config"}, firstchild(), _("Settings"), 40).index = true
	entry({"admin", "mmdvm", "config", "general"}, cbi("mmdvm/config_general"), _("General"), 41)
	entry({"admin", "mmdvm", "config", "dvmode"}, cbi("mmdvm/config_dvmode"), _("Digital Modes"), 42)
	if nixio.fs.access("/etc/init.d/dapnetgateway") then
		entry({"admin", "mmdvm", "config", "pocsag"}, cbi("mmdvm/config_pocsag"), _("POCSAG"), 43)
	end

	entry({"admin", "mmdvm", "advanced"}, firstchild(), _("Advanced"), 100)
	entry({"admin", "mmdvm", "advanced", "mmdvmhost"}, form("mmdvm/mmdvmhost_tab"), _("MMDVMHost"), 11).leaf = true
	entry({"admin", "mmdvm", "advanced", "ysf"}, form("mmdvm/ysfgateway_tab"), _("YSF GW"), 12).leaf = true
	entry({"admin", "mmdvm", "advanced", "p25"}, form("mmdvm/p25gateway_tab"), _("P25 GW"), 13).leaf = true
	entry({"admin", "mmdvm", "advanced", "nxdn"}, form("mmdvm/nxdngateway_tab"), _("NXDN GW"), 14).leaf = true
	entry({"admin", "mmdvm", "advanced", "ircDDB"}, form("mmdvm/ircddbgateway_tab"), _("ircDDB GW"), 15).leaf = true

	-- dapnetgateway is optional 
	if nixio.fs.access("/etc/init.d/dapnetgateway") then
		entry({"admin", "mmdvm", "advanced", "dapnet"}, form("mmdvm/dapnetgateway_tab"), _("DAPNET GW"), 150).leaf = true	
	end
	entry({"admin", "mmdvm", "log"}, firstchild(), _("Live Log"), 999)
	entry({"admin", "mmdvm", "log", "mmdvmhost"}, call("action_livelog", {title="MMDVMHost", log="host"}), _("MMDVMHost"), 21).leaf = true
	entry({"admin", "mmdvm", "log", "ysf"}, call("action_livelog", {title="YSFGateway", log="ysf"}), _("YSF GW"), 22).leaf = true
	entry({"admin", "mmdvm", "log", "p25"}, call("action_livelog", {title="P25Gateway", log="p25"}), _("P25 GW"), 23).leaf = true
	entry({"admin", "mmdvm", "log", "nxdn"}, call("action_livelog", {title="NXDNGateway", log="nxdn"}), _("NXDN GW"), 24).leaf = true
	entry({"admin", "mmdvm", "log", "ircddb"}, call("action_livelog", {title="ircDDBGateway", log="ircddb"}), _("ircDDB GW"), 25).leaf = true

	if nixio.fs.access("/etc/init.d/dapnetgateway") then
		entry({"admin", "mmdvm", "log", "dapnet"}, call("action_livelog", {title="DAPNETGateway", log="dapnet"}), _("DAPNET GW"), 26).leaf = true
	end
end

function action_livelog(argv)
	luci.template.render("mmdvm/logread", argv)
end