module("luci.controller.weburl", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/weburl") then return end

    entry({"admin", "control"}, firstchild(), "Control", 44).dependent = false
    local page = entry({"admin", "control", "weburl"}, cbi("weburl"), _("网址过滤"), 12)
	page.dependent = true
	page.acl_depends = { "luci-app-weburl" }
    entry({"admin", "control", "weburl", "status"}, call("status")).leaf = true
end

function status()
    local e = {}
    e.status = luci.sys.call("iptables -L FORWARD |grep WEBURL >/dev/null") == 0
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
