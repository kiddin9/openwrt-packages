module("luci.controller.cloudreve",package.seeall)

function index()
	entry({"admin", "nas"}, firstchild(), _("NAS") , 45).dependent = false
  if not nixio.fs.access("/etc/config/cloudreve")then
    return
  end
  entry({"admin","nas","cloudreve"},cbi("cloudreve"),_("Cloudreve")).acl_depends = { "luci-app-cloudreve" }
  entry({"admin","nas","cloudreve","status"},call("act_status")).leaf=true
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep cloudreve >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end
