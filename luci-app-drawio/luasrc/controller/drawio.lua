
module("luci.controller.drawio", package.seeall)

function index()
  entry({"admin", "services", "drawio"}, alias("admin", "services", "drawio", "config"), _("DrawIO"), 30).dependent = true
  entry({"admin", "services", "drawio", "config"}, cbi("drawio"))
end
