
module("luci.controller.unifi", package.seeall)

function index()
  entry({"admin", "services", "unifi"}, alias("admin", "services", "unifi", "config"), _("UnifiController"), 30).dependent = true
  entry({"admin", "services", "unifi", "config"}, cbi("unifi"))
end
