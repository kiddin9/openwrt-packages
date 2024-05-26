
module("luci.controller.xunlei", package.seeall)

function index()
  entry({"admin", "services", "xunlei"}, alias("admin", "services", "xunlei", "config"), _("Xunlei"), 30).dependent = true
  entry({"admin", "services", "xunlei", "config"}, cbi("xunlei"))
end
