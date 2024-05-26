
module("luci.controller.gogs", package.seeall)

function index()
  entry({"admin", "services", "gogs"}, alias("admin", "services", "gogs", "config"), _("Gogs"), 30).dependent = true
  entry({"admin", "services", "gogs", "config"}, cbi("gogs"))
end
