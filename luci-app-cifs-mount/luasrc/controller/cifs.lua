module("luci.controller.cifs", package.seeall)

function index()
	entry({"admin", "nas"}, firstchild(), _("NAS") , 45).dependent = false
	if not nixio.fs.access("/etc/config/cifs") then
		return
	end
	
	entry({"admin", "nas", "cifs"}, cbi("cifs"), _("Mount SMB NetShare")).dependent = true
end
