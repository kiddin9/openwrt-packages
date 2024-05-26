-- Copyright (C) 2020 mingxiaoyu <fengying0347@163.com>
-- Licensed to the public under the GNU General Public License v3.
module("luci.controller.cloudflarespeedtest",package.seeall)

function index()

	if not nixio.fs.access('/etc/config/cloudflarespeedtest') then
		return
	end

	local page
	page = entry({"admin", "services", "cloudflarespeedtest"}, firstchild(), _("Cloudflare Speed Test"), 99)
	page.dependent = false
	page.acl_depends = { "luci-app-cloudflarespeedtest" }

	entry({"admin", "services", "cloudflarespeedtest", "general"}, cbi("cloudflarespeedtest/cloudflarespeedtest"), _("Base Setting"), 1)
	entry({"admin", "services", "cloudflarespeedtest", "logread"}, form("cloudflarespeedtest/logread"), _("Logs"), 2)

	entry({"admin", "services", "cloudflarespeedtest", "status"}, call("act_status")).leaf = true
	entry({"admin", "services", "cloudflarespeedtest", "stop"}, call("act_stop"))
	entry({"admin", "services", "cloudflarespeedtest", "start"}, call("act_start"))
	entry({"admin", "services", "cloudflarespeedtest", "getlog"}, call("get_log"))
end

function act_status()
	local e = {}
	e.running = luci.sys.call("busybox ps -w | grep cdnspeedtest | grep -v grep >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function act_stop()
 	luci.sys.call("busybox ps -w | grep cdnspeedtest | grep -v grep | xargs kill -9 >/dev/null")
	luci.http.write('')
end

function act_start()
	act_stop()
	luci.sys.call("/usr/bin/cloudflarespeedtest/cloudflarespeedtest.sh start")
	luci.http.write('')
end

function get_log()
	local fs = require "nixio.fs"
	local e = {}
	e.running = luci.sys.call("busybox ps -w | grep cdnspeedtest | grep -v grep >/dev/null") == 0
	e.log= fs.readfile("/var/log/cloudflarespeedtest.log") or ""	 
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
