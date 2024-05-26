--[[
	walkingsky
	tangxn_1@163.com
]]--

module("luci.controller.wifidog", package.seeall)


function index()
	local fs = require "nixio.fs"
	--if fs.access("/usr/bin/wifidog") then
		entry({"admin", "services","wifidog"}, cbi("wifidog/wifidog_cfg"), "wifidog配置")
	--end
	
end

