
module("luci.controller.lanraragi", package.seeall)

function index()
  entry({"admin", "services", "lanraragi"}, alias("admin", "services", "lanraragi", "config"), _("LANraragi"), 30).dependent = true
  entry({"admin", "services", "lanraragi", "config"}, cbi("lanraragi"))
end
