
module("luci.controller.wxedge", package.seeall)

function index()
  entry({"admin", "services", "wxedge"}, alias("admin", "services", "wxedge", "config"), _("Onething Edge"), 30).dependent = true
  entry({"admin", "services", "wxedge", "config"}, cbi("wxedge"))
end
