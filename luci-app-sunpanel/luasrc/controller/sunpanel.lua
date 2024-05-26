module("luci.controller.sunpanel", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/sunpanel") then
		return
	end

	entry({"admin", "services", "sunpanel"}, cbi("sunpanel"), _("SunPanel"), 20).dependent = true

	entry({"admin", "services", "sunpanel_status"}, call("sunpanel_status"))
end

function sunpanel_status()
	local sys  = require "luci.sys"
	local uci  = require "luci.model.uci".cursor()
	local port = tonumber(uci:get_first("sunpanel", "sunpanel", "port"))

	local status = {
		running = (sys.call("pidof sunpanelbin >/dev/null") == 0),
		port = (port or 8897)
	}

	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end

