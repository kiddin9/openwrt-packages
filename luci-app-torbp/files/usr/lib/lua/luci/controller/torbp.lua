module("luci.controller.torbp", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/torbp") then
		return
	end
	local page
	page = entry({"admin", "services", "torbp"}, cbi("torbp"), _("Tor bridges proxy"))
	page.dependent = true
end
