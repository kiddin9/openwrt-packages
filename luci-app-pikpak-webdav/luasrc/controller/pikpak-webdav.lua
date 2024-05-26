module("luci.controller.pikpak-webdav", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/pikpak-webdav") then
		return
	end
	entry({"admin", "services", "pikpak-webdav"}, alias("admin", "services", "pikpak-webdav", "client"),_("Pikpak WebDAV"), 10).dependent = true  -- 首页
	entry({"admin", "services", "pikpak-webdav", "client"}, cbi("pikpak-webdav/client"),_("Settings"), 10).leaf = true  -- 客户端配置
	entry({"admin", "services", "pikpak-webdav", "log"}, form("pikpak-webdav/log"),_("Log"), 30).leaf = true -- 日志页面

	entry({"admin", "services", "pikpak-webdav", "status"}, call("action_status")).leaf = true
	entry({"admin", "services", "pikpak-webdav", "logtail"}, call("action_logtail")).leaf = true
end

function action_status()
	local e = {}
	e.running = luci.sys.call("pidof pikpak-webdav >/dev/null") == 0
	e.application = luci.sys.exec("pikpak-webdav --version")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function action_logtail()
	local fs = require "nixio.fs"
	local log_path = "/var/log/pikpak-webdav.log"
	local e = {}
	e.running = luci.sys.call("pidof pikpak-webdav >/dev/null") == 0
	if fs.access(log_path) then
		e.log = luci.sys.exec("tail -n 100 %s | sed 's/\\x1b\\[[0-9;]*m//g'" % log_path)
	else
		e.log = ""
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
