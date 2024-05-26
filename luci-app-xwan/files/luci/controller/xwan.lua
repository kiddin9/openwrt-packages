-- Copyright 2019 X-WRT <dev@x-wrt.com>

module("luci.controller.xwan", package.seeall)

function index()
	local page

	page = entry({"admin", "network", "xwan"}, cbi("xwan/xwan"), _("Xwan"))
	page.leaf = true
	page.acl_depends = { "luci-app-xwan" }
end
