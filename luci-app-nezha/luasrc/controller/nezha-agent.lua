module("luci.controller.nezha-agent", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/nezha-agent") then
		return
	end
	entry({"admin", "services", "nezha-agent"}, cbi("nezha-agent"), _("Nezha Agent"), 300).dependent = true
	entry({"admin","services","nezha-agent","status"},call("act_status")).leaf=true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep nezha-agent >/dev/null")==0
	e.enabled=luci.sys.exec("uci get nezha-agent.config.enabled")
	e.tls=luci.sys.exec("uci get nezha-agent.config.tls")
	
	luci.sys.call("/etc/init.d/nezha-agent enable")
	-- e.port=luci.sys.exec("uci get nezha-agent.config.port")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
