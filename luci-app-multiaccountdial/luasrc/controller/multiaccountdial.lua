module("luci.controller.multiaccountdial", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/multiaccountdial") then
		return
	end
	entry({"admin", "network", "multiaccountdial"}, cbi("multiaccountdial"), _("多账号多拨"), 103).dependent = true
	entry({"admin", "network", "multiaccountdial_redial"}, call("redial"), nil).leaf = true
	entry({"admin", "network", "add_vwan"}, call("add_vwan"), nil).leaf = true
	entry({"admin", "network", "del_vwan"}, call("del_vwan"), nil).leaf = true
  entry({"admin", "network", "syncdial_status"}, call("act_status")).leaf = true
end

function redial()
	os.execute("/usr/libexec/multiaccountdial/multi_account_dial redial")
	os.execute("logger -t multiaccountdial redial")
end


function add_vwan()
	os.execute("/usr/libexec/multiaccountdial/multi_account_dial add")
	os.execute("logger -t multiaccountdial add_vwan")
end

function del_vwan()
	os.execute("/usr/libexec/multiaccountdial/multi_account_dial del")
	os.execute("logger -t multiaccountdial del_vwan")
end

function act_status()
	local e = {}
	local num_online = luci.util.exec("/usr/libexec/multiaccountdial/multi_account_dial count_online")
	e.num_online = num_online
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
