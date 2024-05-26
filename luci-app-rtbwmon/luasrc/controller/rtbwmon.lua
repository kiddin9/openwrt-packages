module("luci.controller.rtbwmon", package.seeall)

function index()
	entry({"admin", "status", "rtbwmon"}, template("rtbwmon/rtbwmon"), _("Realtime Bandwidth"), 90)
	entry({"admin", "status", "rtbwmon", "data"}, call("data"))
	entry({"admin", "status", "rtbwmon", "ifaces"}, call("ifaces"))
end

function data()
	luci.http.prepare_content("text/csv")
	luci.http.write(luci.sys.exec("/usr/libexec/rtbwmon.sh update"))
end

function ifaces()
	luci.http.prepare_content("text/csv")
	luci.http.write(luci.sys.exec("/usr/libexec/rtbwmon.sh ifaces"))
end
