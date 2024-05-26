
module("luci.controller.nextcloud", package.seeall)

function index()
  entry({"admin", "services", "nextcloud"}, alias("admin", "services", "nextcloud", "config"), _("Nextcloud"), 30).dependent = true
  entry({"admin", "services", "nextcloud", "config"}, cbi("nextcloud"))
end
