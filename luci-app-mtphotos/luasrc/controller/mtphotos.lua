
module("luci.controller.mtphotos", package.seeall)

function index()
  entry({"admin", "services", "mtphotos"}, alias("admin", "services", "mtphotos", "config"), _("MTPhotos"), 30).dependent = true
  entry({"admin", "services", "mtphotos", "config"}, cbi("mtphotos"))
end
