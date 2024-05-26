
module("luci.controller.excalidraw", package.seeall)

function index()
  entry({"admin", "services", "excalidraw"}, alias("admin", "services", "excalidraw", "config"), _("Excalidraw"), 30).dependent = true
  entry({"admin", "services", "excalidraw", "config"}, cbi("excalidraw"))
end
