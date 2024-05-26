
module("luci.controller.heimdall", package.seeall)

function index()
  entry({"admin", "services", "heimdall"}, alias("admin", "services", "heimdall", "config"), _("Heimdall"), 30).dependent = true
  entry({"admin", "services", "heimdall", "config"}, cbi("heimdall"))
end
