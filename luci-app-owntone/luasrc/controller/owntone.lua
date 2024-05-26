
module("luci.controller.owntone", package.seeall)

function index()
  entry({"admin", "services", "owntone"}, alias("admin", "services", "owntone", "config"), _("Owntone"), 30).dependent = true
  entry({"admin", "services", "owntone", "config"}, cbi("owntone"))
end
