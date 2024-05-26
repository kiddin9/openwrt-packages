module("luci.controller.homebox", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/homebox") then
		return
	end

	entry({"admin", "services", "homebox"}, cbi("homebox"), _("Homebox"), 20).dependent = true

	entry({"admin", "services", "homebox_status"}, call("homebox_status"))
end

function homebox_status()
	local sys  = require "luci.sys"
	local uci  = require "luci.model.uci".cursor()

	local status = {
		running = (sys.call("pidof homebox >/dev/null 2>&1") == 0),
		port = 3300
	}

	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end
