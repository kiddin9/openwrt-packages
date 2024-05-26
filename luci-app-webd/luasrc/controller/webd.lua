module("luci.controller.webd",package.seeall)

function index()
	entry({"admin", "nas"}, firstchild(), _("NAS") , 45).dependent = false
	if not nixio.fs.access("/etc/config/webd") then
		return
	end

	entry({"admin", "nas", "webd"}, cbi("webd"), _("Webd Netdisk"),99)
	entry({"admin", "nas", "webd", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.running = luci.sys.call("pgrep webd > /dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
