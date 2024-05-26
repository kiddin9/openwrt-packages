
module("luci.controller.penpot", package.seeall)

function index()
  entry({"admin", "services", "penpot"}, alias("admin", "services", "penpot", "config"), _("Penpot"), 30).dependent = true
  entry({"admin", "services", "penpot", "config"}, cbi("penpot/config"), _("Config"), 10).leaf = true
  entry({"admin", "services", "penpot", "tool"}, form("penpot/tool"), _("Tool"), 30).leaf = true
end
