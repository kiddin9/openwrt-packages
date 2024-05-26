local ucic = luci.model.uci.cursor()
local dt = require "luci.cbi.datatypes"
module("luci.controller.snmpd", package.seeall)

function index()
	entry({"admin", "network", "snmpd"}, alias("admin", "network", "snmpd", "index"), _("SNMPd"))
	entry({"admin", "network", "snmpd", "index"}, cbi("snmpd"))
end
