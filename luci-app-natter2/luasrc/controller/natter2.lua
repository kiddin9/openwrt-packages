module("luci.controller.natter2",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/natter2")then
		return
	end
	entry({"admin","network","natter2"},alias("admin","network","natter2","base"),_("Natter v2"),99).dependent=true
	entry({"admin","network","natter2","base"},cbi("natter2/base"),_("Base Settings"),10).leaf=true
	entry({"admin","network","natter2","instances"},cbi("natter2/instances")).leaf=true
	entry({"admin","network","natter2","log"},form("natter2/log"),_("Log"),20).leaf=true
	entry({"admin","network","natter2","print_log"},call("print_log")).leaf=true
	entry({"admin","network","natter2","del_log"},call("del_log")).leaf=true
end

function print_log()
	luci.http.write(luci.sys.exec("sh /usr/share/luci-app-natter2/log.sh print"))
end

function del_log()
	luci.http.write(luci.sys.exec("sh /usr/share/luci-app-natter2/log.sh del"))
end
