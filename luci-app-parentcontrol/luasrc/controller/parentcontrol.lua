module("luci.controller.parentcontrol", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/parentcontrol") then return end

        entry({"admin", "control"}, firstchild(), "Control", 44).dependent = false
	local e = entry({"admin","control","parentcontrol"},firstchild(),_("Parent Control"),2)
	e.dependent=false
	e.acl_depends = { "luci-app-parentcontrol" }
	entry({"admin","control","parentcontrol","time"},cbi("parentcontrol/time"),_("Time Control"),1).leaf=true
	entry({"admin", "control", "parentcontrol","weburl"}, cbi("parentcontrol/weburl"), _("Weburl Control"), 20).leaf = true
        entry({"admin", "control", "parentcontrol","protocol"}, cbi("parentcontrol/protocol"), _("Protocol Control"), 30).leaf = true 
	entry({"admin", "control", "parentcontrol","status"}, call("status")).leaf = true
end

function status()
    local e = {} 
    e.status = luci.sys.call("iptables -L FORWARD | grep PARENTCONTROL >/dev/null || iptables -L INPUT | grep PARENTCONTROL >/dev/null || iptables -L OUTPUT | grep PARENTCONTROL >/dev/null") == 0
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
