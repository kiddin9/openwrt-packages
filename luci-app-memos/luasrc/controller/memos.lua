
module("luci.controller.memos", package.seeall)

function index()
  entry({"admin", "services", "memos"}, alias("admin", "services", "memos", "config"), _("Memos"), 30).dependent = true
  entry({"admin", "services", "memos", "config"}, cbi("memos"))
end
