module("luci.controller.lingti",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/lingti") then return end

	entry({"admin", "services", "lingti"}, cbi("lingti/lingti"), ("LingTi GameAcc"),99).dependent=true
	entry({"admin","services","lingti","status"},call("act_status")).leaf=true
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep -f lingti >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end