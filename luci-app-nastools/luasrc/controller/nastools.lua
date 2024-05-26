
module("luci.controller.nastools", package.seeall)

function index()
  entry({"admin", "services", "nastools"}, alias("admin", "services", "nastools", "config"), _("NasTools"), 30).dependent = true
  entry({"admin", "services", "nastools", "config"}, cbi("nastools"))
end
