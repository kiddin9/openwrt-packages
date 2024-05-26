module("luci.controller.airconnect", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/airconnect") then
		return
	end

	local page = entry({"admin", "services", "airconnect"}, cbi("airconnect"), _("AirConnect"))
	page.dependent = true
	page.acl_depends = { "luci-app-airconnect" }

	entry({"admin", "services", "airconnect", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.running = luci.sys.call("pgrep aircast >/dev/null") == 0 or luci.sys.call("pgrep airupnp >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
