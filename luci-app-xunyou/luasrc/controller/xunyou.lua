module("luci.controller.xunyou", package.seeall)

function index()
	entry({"admin", "services", "xunyou"}, alias("admin", "services", "xunyou", "main"), _("xunyou"), 10).dependent = true -- 首页
	entry({"admin", "services", "xunyou", "main"}, cbi("xunyou/main"), _("xunyou"), 20).leaf = true
	entry({"admin", "services", "xunyou", "status"}, call("xunyou_status"))
end

local sys  = require "luci.sys"
local uci  = require "luci.model.uci".cursor()
local util  = require("luci.util")
local fs = require "nixio.fs"
local os   = require "os"

function xunyou_status()
	local rc = os.execute("/xunyou/xunyou_daemon.sh status >/dev/null 2>&1")

	local running = rc == 0
	local lanmac
	if running then
		local interface = uci:get_first("xunyou", "xunyou", "interface", "lan")
		interface = util.exec(". /lib/functions/network.sh ; network_is_up "..interface.." || exit 0 ; network_get_device device "..interface.."; echo ${device} ")
        interface = util.trim(interface)
        interface = interface or "br-lan"
		lanmac = util.trim(fs.readfile("/sys/class/net/"..interface.."/address"))
	end
	local status = {
		running = running,
		lanmac = lanmac
	}

	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
	return status
end
