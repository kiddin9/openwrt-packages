
module("luci.controller.vaultwarden", package.seeall)

function index()
  entry({"admin", "services", "vaultwarden"}, alias("admin", "services", "vaultwarden", "config"), _("Vaultwarden"), 30).dependent = true
  entry({"admin", "services", "vaultwarden", "config"}, cbi("vaultwarden"))
end
