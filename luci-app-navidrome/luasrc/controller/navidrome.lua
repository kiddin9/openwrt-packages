
module("luci.controller.navidrome", package.seeall)

function index()
  entry({"admin", "services", "navidrome"}, alias("admin", "services", "navidrome", "config"), _("Navidrome"), 30).dependent = true
  entry({"admin", "services", "navidrome", "config"}, cbi("navidrome"))
end
