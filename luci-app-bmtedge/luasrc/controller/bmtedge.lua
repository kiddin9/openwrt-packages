
module("luci.controller.bmtedge", package.seeall)

function index()
  entry({"admin", "services", "bmtedge"}, alias("admin", "services", "bmtedge", "config"), _("BlueMountain Edge"), 30).dependent = true
  entry({"admin", "services", "bmtedge", "config"}, cbi("bmtedge"))
end
