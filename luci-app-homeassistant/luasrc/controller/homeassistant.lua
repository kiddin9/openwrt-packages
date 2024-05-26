
module("luci.controller.homeassistant", package.seeall)

function index()
  entry({"admin", "services", "homeassistant"}, alias("admin", "services", "homeassistant", "config"), _("Home Assistant"), 30).dependent = true
  entry({"admin", "services", "homeassistant", "config"}, cbi("homeassistant/config"), _("Config"), 10).leaf = true
  entry({"admin", "services", "homeassistant", "tool"}, form("homeassistant/tool"), _("Tool"), 30).leaf = true
  entry({"admin", "services", "homeassistant", "console"}, form("homeassistant/console"), _("Console"), 50).leaf = true
end
