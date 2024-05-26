-- N2N Luci configuration page. Made by 981213

module("luci.controller.n2n", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/n2n") then
		return
	end

	entry({"admin", "vpn"}, firstchild(), "VPN", 45).dependent = false
	entry({"admin", "vpn", "n2n"}, cbi("n2n"), _("N2N VPN"), 45).dependent = true
	entry({"admin", "vpn", "n2n", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.running = luci.sys.call("pgrep n2n-edge >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
