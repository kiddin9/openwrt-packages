-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Licensed to the public under the Apache License 2.0.

local NXFS = require "nixio.fs"
local DISP = require "luci.dispatcher"
local HTTP = require "luci.http"
local UCI = luci.model.uci.cursor()

m = Map("autorepeater")
m.title = [[<a href="]] .. DISP.build_url("admin", "services", "autorepeater") .. [[">]] ..
		translate("Auto Repeater") .. [[</a>]]

m.description = translate("Auto Repeater helps you turn your router as a repeater, " ..
			"join a wireless station by scan station ssid or bssid first.")

m.redirect = DISP.build_url("admin", "services", "autorepeater")

-- log directory
log_dir = UCI:get_first(m.config, "global", "log_dir") or "/var/log/autorepeater"
run_dir = UCI:get_first(m.config, "global", "run_dir") or "/var/run/autorepeater"
local logfile_list = {}
for path in (NXFS.glob("%s/*" % log_dir) or function() end) do
	logfile_list[#logfile_list+1] = path
end
for path in (NXFS.glob("%s/*" % run_dir) or function() end) do
	logfile_list[#logfile_list+1] = path
end

ns = m:section(TypedSection, "_dummy", translate("Log File Viewer"))
ns.addremove = false
ns.anonymous = true
function ns.cfgsections()
	return{"_exrules"}
end

lv = ns:option(DynamicList, "logfiles")
lv.template = "autorepeater/logsview"
lv.inputtitle = translate("Read / Reread log file")
lv.rows = 25
lv.default = ""
for _, lfile in ipairs(logfile_list) do lv:value(lfile, lfile) end
function lv.cfgvalue(self, section)
	if logfile_list[1] then
		local lfile=logfile_list[1]
		if NXFS.access(lfile) then
			return lfile .. "\n" .. translate("Please press [Read] button")
		end
		return lfile .. "\n" .. translate("File not found or empty")
	else
		return log_dir .. "\/\n" .. translate("No files found")
	end
end

return m
