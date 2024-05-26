
module("luci.controller.photoprism", package.seeall)

function index()
  entry({"admin", "services", "photoprism"}, alias("admin", "services", "photoprism", "config"), _("PhotoPrism"), 30).dependent = true
  entry({"admin", "services", "photoprism", "config"}, cbi("photoprism"))
end
