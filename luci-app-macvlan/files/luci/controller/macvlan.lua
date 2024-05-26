-- Copyright (C) 2019 X-WRT <dev@x-wrt.com>

module("luci.controller.macvlan", package.seeall)

function index()
	local page

	page = entry({"admin", "network", "macvlan"}, cbi("macvlan/macvlan"), _("Macvlan"))
	page.leaf = true
	page.acl_depends = { "luci-app-macvlan" }
end
