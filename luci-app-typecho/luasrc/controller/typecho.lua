
module("luci.controller.typecho", package.seeall)

function index()
  entry({"admin", "services", "typecho"}, alias("admin", "services", "typecho", "config"), _("TypeCho"), 30).dependent = true
  entry({"admin", "services", "typecho", "config"}, cbi("typecho"))
end
