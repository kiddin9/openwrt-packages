
module("luci.controller.chinesesubfinder", package.seeall)

function index()
  entry({"admin", "services", "chinesesubfinder"}, alias("admin", "services", "chinesesubfinder", "config"), _("ChineseSubFinder"), 30).dependent = true
  entry({"admin", "services", "chinesesubfinder", "config"}, cbi("chinesesubfinder"))
end
