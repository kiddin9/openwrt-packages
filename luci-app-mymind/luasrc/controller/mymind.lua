
module("luci.controller.mymind", package.seeall)

function index()
  entry({"admin", "services", "mymind"}, alias("admin", "services", "mymind", "config"), _("MyMind"), 30).dependent = true
  entry({"admin", "services", "mymind", "config"}, cbi("mymind"))
end
