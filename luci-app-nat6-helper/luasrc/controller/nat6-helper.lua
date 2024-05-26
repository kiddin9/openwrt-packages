
module("luci.controller.nat6-helper", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/nat6-helper") then
		return
	end

	entry({"admin", "services", "nat6-helper"},firstchild(), _("NAT6 配置助手"), 50).dependent = false
	
	entry({"admin", "services", "nat6-helper", "general"},cbi("nat6-helper"), _("设置"), 1)

	entry({"admin", "services", "nat6-helper", "status"},call("act_status")).leaf=true
	
end

function act_status()
	local e={}
	e.running=luci.sys.call("ip6tables -t nat -L | grep 'v6NAT' > /dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
