module("luci.controller.natter",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/natter") then
		return
	end
	entry({"admin", "network", "natter"}, alias("admin", "network", "natter", "base"), _("Natter"), 99).dependent = true
	entry({"admin", "network", "natter", "base"}, cbi("natter/base"), _("Base Settings"), 10).leaf = true
	entry({"admin", "network", "natter", "ports"}, cbi("natter/ports")).leaf = true
	entry({"admin", "network", "natter", "log"}, form("natter/log"), _("Log"), 20).leaf = true
	entry({"admin", "network", "natter", "print_log"}, call("print_log")).leaf = true
	entry({"admin", "network", "natter", "del_log"}, call("del_log")).leaf = true
end

function print_log()
	luci.http.write(luci.sys.exec("sh /usr/share/luci-app-natter/log.sh print"))
end

function del_log()
	luci.http.write(luci.sys.exec("sh /usr/share/luci-app-natter/log.sh del"))
end
