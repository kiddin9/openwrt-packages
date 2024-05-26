
module("luci.controller.plex", package.seeall)

function index()
  entry({"admin", "services", "plex"}, alias("admin", "services", "plex", "config"), _("Plex"), 30).dependent = true
  entry({"admin", "services", "plex", "config"}, cbi("plex"))
end
