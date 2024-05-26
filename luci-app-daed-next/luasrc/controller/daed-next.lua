local sys  = require "luci.sys"
local http = require "luci.http"

module("luci.controller.daed-next", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/daed-next") then
		return
	end

    local page = entry({"admin", "services", "daed-next"}, alias("admin", "services", "daed-next", "basic"), _("DAED Next"), -1)
    page.dependent = true
    page.acl_depends = { "luci-app-daed-next" }

	entry({"admin", "services", "daed-next", "basic"}, cbi("daed-next/basic"), _("Basic Setting"), 1).leaf = true
	entry({"admin", "services", "daed-next", "dashboard"}, template("daed-next/dashboard"), _("Dashboard"), 2).leaf = true
	entry({"admin", "services", "daed-next", "log"}, cbi("daed-next/log"), _("Logs"), 3).leaf = true
	entry({"admin", "services", "daed-next", "status"}, call("act_status")).leaf = true
	entry({"admin", "services", "daed-next", "get_log"}, call("get_log")).leaf = true
	entry({"admin", "services", "daed-next", "clear_log"}, call("clear_log")).leaf = true
end

function act_status()
	local e = {}
	e.running = sys.call("pgrep -x /usr/bin/dae-wing >/dev/null") == 0
	http.prepare_content("application/json")
	http.write_json(e)
end

function get_log()
	http.write(sys.exec("cat /var/log/daed-next/daed-next.log"))
end

function clear_log()
	sys.call("true > /var/log/daed-next/daed-next.log")
end
