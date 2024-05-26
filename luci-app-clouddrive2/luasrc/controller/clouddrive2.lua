
module("luci.controller.clouddrive2", package.seeall)

function index()
  entry({"admin", "services", "clouddrive2"}, alias("admin", "services", "clouddrive2", "config"), _("CloudDrive2"), 30).dependent = true
  entry({"admin", "services", "clouddrive2", "config"}, cbi("clouddrive2"))
end
