module("luci.controller.homebridge",package.seeall)
function index()
if not nixio.fs.access("/etc/config/homebridge")then
return
end

entry({"admin","services","homebridge"},
	alias("admin","services","homebridge","general"),
	_("Homebridge"),1).dependent=true

entry({"admin", "services", "homebridge", "general"},
	cbi("homebridge/general"),
	_("Settings"), 1).leaf=true

entry({"admin", "services", "homebridge", "platforms"},
	arcombine(cbi("homebridge/platforms"),cbi("homebridge/platform-config")),
	_("Platform Settings"), 2).leaf=true

--entry({"admin", "services", "homebridge", "accessories"},
--	arcombine(cbi("homebridge/accessories"),cbi("homebridge/accessory-config")),
--	_("Accessory Settings"), 3).leaf=true

entry({"admin","services","homebridge","log"}, 
	template("homebridge/logview"), 
	_("Log"), 4).leaf=true

entry({"admin","services","homebridge","status"},
	call("act_status")).leaf=true
entry({"admin","services","homebridge","process_status"},
	call("act_process_status")).leaf=true
entry({"admin","services","homebridge","logdata"},
	call("act_log")).leaf=true
end

function act_status()
local e={}
e.running=luci.sys.call("pgrep homebridge >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end

function act_process_status()
	local e={}
	local section = luci.http.formvalue("section")
	luci.sys.call("sleep 3")
	e.index = luci.http.formvalue("index")
	e.run = luci.sys.call("/usr/share/homebridge/process_status.sh " .. section .. " >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function act_log()
local log_data = {}

log_data = nixio.fs.readfile("/var/log/homebridge.log") or ""
luci.http.prepare_content("application/json")
luci.http.write_json(log_data)
end
