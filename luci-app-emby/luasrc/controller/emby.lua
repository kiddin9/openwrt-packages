
module("luci.controller.emby", package.seeall)

function index()
  entry({"admin", "services", "emby"}, alias("admin", "services", "emby", "config"), _("Emby"), 30).dependent = true
  entry({"admin", "services", "emby", "config"}, cbi("emby"))
end
