
module("luci.controller.xteve", package.seeall)

function index()
  entry({"admin", "services", "xteve"}, alias("admin", "services", "xteve", "config"), _("Xteve"), 30).dependent = true
  entry({"admin", "services", "xteve", "config"}, cbi("xteve"))
end
