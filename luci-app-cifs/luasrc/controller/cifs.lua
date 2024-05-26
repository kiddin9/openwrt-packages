-- Copyright 2015
-- Matthew
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.cifs", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cifs") then
		return
	end

	local page = entry({"admin", "services", "cifs"}, cbi("cifs"), _("Mounting NAT drives"))
	page.dependent = true
	page.acl_depends = { "luci-app-cifs" }

	entry({"admin", "services", "cifs", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.running = luci.sys.call("pidof cifsd > /dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
