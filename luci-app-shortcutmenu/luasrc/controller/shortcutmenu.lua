-- Copyright 2021 sudodou <wsdoshb@gmail.com>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.shortcutmenu", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/shortcutmenu") then
		return
	end
	entry({"admin", "status", "shortcutmenu"}, cbi("shortcutmenu"), _("Shortcutmenu"), 55).dependent = true
end
