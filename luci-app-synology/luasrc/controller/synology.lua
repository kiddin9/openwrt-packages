module("luci.controller.synology", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/synology") then return end
    local page
	page = entry({"admin", "services", "synology"}, alias("admin", "services", "synology", "machine"), _("黑群晖"), 10)
	page.dependent = true
	entry({'admin', 'services', 'synology', 'machine'}, cbi("synology/machine"), _("虚拟机设置"), 10).leaf = true
	entry({'admin', 'services', 'synology', 'images' }, arcombine(cbi("synology/images"), cbi("synology/images-config")),  _("镜像设置"),   30).leaf = true
	entry({'admin', 'services', 'synology', 'createImages'}, call("action_createImages"))
	entry({'admin', 'services', 'synology', 'createMachine'}, call("action_createMachine"))
	entry({'admin', 'services', 'synology', 'run'}, call('act_status'))
end

function act_status()
	local e = {}
	e.running = luci.sys.call("/usr/bin/pgrep -f 'qemu-system-x86_64 -name synology' >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
