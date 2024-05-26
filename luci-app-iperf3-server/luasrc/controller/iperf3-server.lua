module("luci.controller.iperf3-server",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/iperf3-server") then
		return
	end

	entry({"admin", "services", "iperf3-server"}, cbi("iperf3-server"), _("iPerf3 Server"),99)
	entry({"admin", "services", "iperf3-server", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.running = luci.sys.call("pgrep iperf3 > /dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
