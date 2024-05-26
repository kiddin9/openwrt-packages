-- Copyright (C) 2018 max0y <askmaxwork@gmail.com>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.cd8021x", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cd8021x") then
		return
	end

	local page = entry({"admin", "network", "cd8021x"}, cbi("cd8021x"), _("802.1x Client"))
	page.order = 100
	page.dependent = true
	page.acl_depends = { "luci-app-cd8021x" }
end
