-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Licensed to the public under the Apache License 2.0.

local wa = require "luci.tools.webadmin"
local nw = require "luci.model.network"
local ut = require "luci.util"
local nt = require "luci.sys".net
local fs = require "nixio.fs"
local DISP = require "luci.dispatcher"

arg[1] = arg[1] or ""

m = Map("wireless")
m:chain("network")
m:chain("firewall")

local ifsection

function m.on_commit(map)
	local wnet = nw:get_wifinet(arg[1])
	if ifsection and wnet then
		ifsection.section = wnet.sid
		m.title = [[<a href="]] .. DISP.build_url("admin", "services", "autorepeater") .. [[">]] ..
		translate("Auto Repeater") .. [[</a> - ]] .. ut.pcdata(wnet:get_i18n())
		m.redirect = DISP.build_url("admin", "services", "autorepeater")
	end
end

nw.init(m.uci)

local wnet = nw:get_wifinet(arg[1])
local wdev = wnet and wnet:get_device()

-- redirect to overview page if network does not exist anymore (e.g. after a revert)
if not wnet or not wdev then
	luci.http.redirect(DISP.build_url("admin/services/autorepeater"))
	return
end

m.title = [[<a href="]] .. DISP.build_url("admin", "services", "autorepeater") .. [[">]] ..
	translate("Auto Repeater") .. [[</a> - ]] .. ut.pcdata(wnet:get_i18n())
m.redirect = DISP.build_url("admin", "services", "autorepeater")

return m

