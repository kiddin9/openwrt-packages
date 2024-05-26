module("luci.controller.owntone", package.seeall)

function index()
	entry({"admin", "nas"}, firstchild(), _("NAS") , 45).dependent = false
	if not nixio.fs.access("/etc/config/owntone") then
		return
	end

	entry({"admin", "nas", "owntone"}, cbi("owntone"), _("Music Remote Center")).dependent = true
	entry({"admin", "nas", "owntone", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.running = luci.sys.call("pgrep owntone >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
