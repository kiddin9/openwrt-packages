
module("luci.controller.jellyfin", package.seeall)

function index()
  entry({"admin", "services", "jellyfin"}, alias("admin", "services", "jellyfin", "config"), _("Jellyfin"), 30).dependent = true
  entry({"admin", "services", "jellyfin", "config"}, cbi("jellyfin"))
end
