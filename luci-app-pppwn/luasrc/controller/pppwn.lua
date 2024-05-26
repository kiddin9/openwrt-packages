module("luci.controller.pppwn", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/pppwn") then
		return
	end

	entry({"admin", "services", "pppwn"}, alias("admin", "services", "pppwn", "general"), _("PS4 PPP PWN"), 80)
	entry({"admin", "services", "pppwn", "general"}, cbi("pppwn/settings"), _("Base Setting"), 1)
	entry({"admin", "services", "pppwn", "log"}, form("pppwn/info"), _("Log"), 2)

	entry({"admin", "services", "pppwn", "status"}, call("status")).leaf = true
end

function status()
	local e = {}
	e.running = luci.sys.call("pgrep pppwn >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

