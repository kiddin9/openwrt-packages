-- Copyright 2020 Lienol <lawlienol@gmail.com>

module("luci.controller.socat", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/socat") then
		return
	end

	entry({"admin", "network", "socat"}, alias("admin", "network", "socat", "index"), _("Socat"), 100).dependent = true
	entry({"admin", "network", "socat", "index"}, cbi("socat/index")).leaf = true
	entry({"admin", "network", "socat", "config"}, cbi("socat/config")).leaf = true
	entry({"admin", "network", "socat", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.index = luci.http.formvalue("index")
	e.status = luci.sys.call(string.format("ps -w | grep -v 'grep' | grep '/var/etc/socat/%s' >/dev/null", luci.http.formvalue("id"))) == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
