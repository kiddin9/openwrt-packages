module("luci.controller.shutdown",package.seeall)

function index()
	entry({"admin", "system", "shutdown"}, cbi("shutdown"), _("Shutdown"),99)
end
