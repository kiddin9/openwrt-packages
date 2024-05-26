
module("luci.controller.jackett", package.seeall)

function index()
  entry({"admin", "services", "jackett"}, alias("admin", "services", "jackett", "config"), _("Jackett"), 30).dependent = true
  entry({"admin", "services", "jackett", "config"}, cbi("jackett"))
end
