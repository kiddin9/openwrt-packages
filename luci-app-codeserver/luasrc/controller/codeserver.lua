
module("luci.controller.codeserver", package.seeall)

function index()
  entry({"admin", "services", "codeserver"}, alias("admin", "services", "codeserver", "config"), _("CodeServer"), 30).dependent = true
  entry({"admin", "services", "codeserver", "config"}, cbi("codeserver/config"), _("Config"), 10).leaf = true
  entry({"admin", "services", "codeserver", "tool"}, form("codeserver/tool"), _("Tool"), 30).leaf = true
  entry({"admin", "services", "codeserver", "console"}, form("codeserver/console"), _("Console"), 50).leaf = true
end
