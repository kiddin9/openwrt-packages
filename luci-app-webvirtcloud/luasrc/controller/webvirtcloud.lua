
module("luci.controller.webvirtcloud", package.seeall)

function index()
  entry({"admin", "services", "webvirtcloud"}, alias("admin", "services", "webvirtcloud", "config"), _("KVM WebVirtCloud"), 30).dependent = true
  entry({"admin", "services", "webvirtcloud", "config"}, cbi("webvirtcloud/config"), _("Config"), 10).leaf = true
  entry({"admin", "services", "webvirtcloud", "tool"}, form("webvirtcloud/tool"), _("Tool"), 30).leaf = true
end
