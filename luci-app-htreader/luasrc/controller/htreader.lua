
module("luci.controller.htreader", package.seeall)

function index()
  entry({"admin", "services", "htreader"}, alias("admin", "services", "htreader", "config"), _("HTReader"), 30).dependent = true
  entry({"admin", "services", "htreader", "config"}, cbi("htreader"))
end
