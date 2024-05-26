-- Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

module("luci.controller.mmdvm.public", package.seeall)

local sys   = require("luci.sys")
local util  = require("luci.util")
local http  = require("luci.http")
local i18n  = require("luci.i18n")
local json  = require("luci.jsonc")
local uci   = require("luci.model.uci").cursor()
local mmdvm = require("luci.model.mmdvm")

function index()
	if not nixio.fs.access("/etc/MMDVM.ini") then
		return
	end
	entry({"mmdvm"}, firstchild(), _("Radio"), 1).dependent = false
	entry({"mmdvm", "dashboard"}, call("action_dashboard"), _("Dashboard"), 10).leaf = true
	entry({"mmdvm", "log"}, firstchild(), _("Live Log"), 20)
	entry({"mmdvm", "log", "mmdvmhost"}, call("action_livelog", {title="MMDVMHost", log="host"}), _("MMDVMHost"), 21).leaf = true
	entry({"mmdvm", "log", "ysf"}, call("action_livelog", {title="YSFGateway", log="ysf"}), _("YSF GW"), 22).leaf = true
	entry({"mmdvm", "log", "p25"}, call("action_livelog", {title="P25Gateway", log="p25"}), _("P25 GW"), 23).leaf = true
	entry({"mmdvm", "log", "nxdn"}, call("action_livelog", {title="NXDNGateway", log="nxdn"}), _("NXDN GW"), 24).leaf = true
	entry({"mmdvm", "log", "ircddb"}, call("action_livelog", {title="ircDDBGateway", log="ircddb"}), _("ircDDB GW"), 25).leaf = true
	if nixio.fs.access("/etc/init.d/dapnetgateway") then
		entry({"mmdvm", "log", "dapnet"}, call("action_livelog", {title="DAPNETGateway", log="dapnet"}), _("DAPNET GW"), 26).leaf = true
		entry({"mmdvm", "lastpocsag"}, call("action_last_pocsag"), nil).leaf = true
	end
	entry({"mmdvm", "config"}, alias("admin", "mmdvm", "config"), _("Settings"), 30).index = true

	entry({"mmdvm", "logread"}, call("action_logread"), nil).leaf = true
	entry({"mmdvm", "lastheard"}, call("action_lastheard"), nil).leaf = true
	entry({"mmdvm", "livecall"}, call("action_livecall"))
	entry({"mmdvm", "lc"}, call("action_lc"))

end

function action_livelog(argv)
	luci.template.render("mmdvm/logread", argv)
end

function action_logread(type)
	local n = luci.http.formvalue("pos") or 1
	local content
	local filename
	if type == "host" then
		filename = "MMDVM"
	elseif type == "p25" then
		filename = "P25Gateway"
	elseif type == "ysf" then
		filename = "YSFGateway"
	elseif type == "nxdn" then
		filename = "NXDNGateway"
	elseif type == "dapnet" then
		filename = "DAPNETGateway"
	elseif type == "ircddb" then
		filename = "ircDDBGateway"
	else
		-- illegal request
		http.write("")
		return
	end

	local cmd = "tail -n +%s /var/log/mmdvm/%s-%s.log" % {n, filename, os.date("%Y-%m-%d")}
	content = util.trim(util.exec(cmd))
	http.write(content)
end

function action_dashboard()
	local lastheard = mmdvm.get_lastheard()
	luci.template.render("mmdvm/dashboard", {lastheard = lastheard})
end

function action_lastheard()
	local lastheard = mmdvm.get_lastheard()
	luci.template.render("mmdvm/lastheard", {lastheard = lastheard})
end

function action_last_pocsag()
	local ps = mmdvm.get_last_pocsag()
	luci.template.render("mmdvm/lastpocsag", {pocsags = ps})
end

function action_livecall()
	local lastheard = mmdvm.get_lastheard()
	luci.template.render("mmdvm/livecall", {lastheard = lastheard})
end

function action_lc()
	local lastheard = mmdvm.get_lastheard()
	luci.template.render("mmdvm/lc", {lastheard = lastheard})
end
