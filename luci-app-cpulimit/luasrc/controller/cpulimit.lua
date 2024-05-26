module("luci.controller.cpulimit", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cpulimit") then
		return
	end

	local page = entry({"admin", "system", "cpulimit"}, cbi("cpulimit"), _("cpulimit"), 65)
	page.dependent = true
	page.acl_depends = { "luci-app-cpulimit" }
end
