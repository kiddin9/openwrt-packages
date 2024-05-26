module("luci.controller.nfs", package.seeall)

function index()
	entry({"admin", "nas"}, firstchild(), _("NAS") , 45).dependent = false
	if not nixio.fs.access("/etc/config/nfs") then
		return
	end

	entry({"admin", "nas"}, firstchild(), "NAS", 44).dependent = false
	entry({"admin", "nas", "nfs"}, cbi("nfs"), _("NFS Manage"), 5).dependent = true
end
