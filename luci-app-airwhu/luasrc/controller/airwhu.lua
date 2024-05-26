module("luci.controller.airwhu", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/airwhu") then
		return
	end

	local page = entry({"admin", "services", "airwhu"}, cbi("airwhu"), _("AirWHU"), 100)
	page.dependent = true
	page.acl_depends = { "luci-app-airwhu" }

	entry({"admin", "services", "airwhu", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.running = luci.sys.call("pidof mentohust > /dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
