
module("luci.controller.ittools", package.seeall)

function index()
  entry({"admin", "services", "ittools"}, alias("admin", "services", "ittools", "config"), _("ITTools"), 30).dependent = true
  entry({"admin", "services", "ittools", "config"}, cbi("ittools"))
end
