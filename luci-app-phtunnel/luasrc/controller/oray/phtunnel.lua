module("luci.controller.oray.phtunnel", package.seeall)

function index()
	entry({"admin", "services", "phtunnel"}, alias("admin", "services", "phtunnel", "setup"), _("Phtunnel"))
	entry({"admin", "services", "phtunnel", "setup"}, cbi("oray/phtunnel_setup"), _("Setup"), 1).leaf = true
	entry({"admin", "services", "phtunnel", "status"}, template("oray/phtunnel_status"), _("Status"), 2).leaf = true
	-- entry({"admin", "oray", "phtunnel", "log"}, template("oray/phtunnel_log"), _("Log"), 3).leaf = true

	local node = entry({"admin", "services", "phtunnel", "inner_status"}, template("oray/phtunnel_inner_status"), nil, 4)
	node.leaf = true
	node.hidden = true

	node = entry({"admin", "services", "phtunnel", "log_off"}, template("oray/phtunnel_log_off"), nil, 5)
	node.leaf = true
	node.hidden = true
end
