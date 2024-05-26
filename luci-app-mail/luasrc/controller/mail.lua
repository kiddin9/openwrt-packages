module("luci.controller.mail", package.seeall)

function index()
	entry({"admin", "services", "mail"}, alias("admin", "services", "mail", "index"), _("Mail settings"))
	entry({"admin", "services", "mail", "index"}, cbi("mail"))
end
