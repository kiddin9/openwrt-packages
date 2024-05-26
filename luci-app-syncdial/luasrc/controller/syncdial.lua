module("luci.controller.syncdial", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/syncdial") then
		return
	end

	local page
	page = entry({"admin", "network", "syncdial"}, cbi("syncdial"), _("多线多拨"),103)
	page.dependent = true
	page.acl_depends = { "luci-app-syncdial" }

	page = entry({"admin", "network", "syncdial", "status"}, call("act_status"))
	page.leaf = true
	page = entry({"admin", "network", "macvlan_redial"}, call("redial"), nil)
	page.leaf = true
end

function act_status()
	local e = {}
	local mwan3_status = luci.util.exec("mwan3 status")
	e.num_online = 0
	for _ in mwan3_status:gmatch("tracking is active") do
		e.num_online = e.num_online + 1
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function redial()
	os.execute("killall -9 pppd")
end
