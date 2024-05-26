module("luci.controller.chinadns-ng", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/chinadns-ng") then
		return
	end
	page = entry({"admin", "services", "chinadns-ng"}, cbi("chinadns-ng"), _("ChinaDNS-NG"), 70)
	page.dependent = true
	page.acl_depends = { "luci-app-chinadns-ng" }
end
