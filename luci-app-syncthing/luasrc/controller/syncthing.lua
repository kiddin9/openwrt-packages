
module("luci.controller.syncthing", package.seeall)

function index()
	entry({"admin", "nas"}, firstchild(), _("NAS") , 45).dependent = false
	if not nixio.fs.access("/etc/config/syncthing") then
		return
	end
	
	local page = entry({"admin", "nas", "syncthing"}, cbi("syncthing"), _("Syncthing"))
	page.order = 10
	page.dependent = true
	page.acl_depends = { "luci-app-syncthing" }
	entry({"admin","nas","syncthing","status"},call("act_status")).leaf=true
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep syncthing >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end
