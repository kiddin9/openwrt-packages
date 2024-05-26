--[[
LuCI - Lua Configuration Advancedplus
 Copyright (C) 2022-2024  sirpdboy <herboy2008@gmail.com> https://github.com/sirpdboy/luci-app-advancedplus
]]--

local fs = require "nixio.fs"
local http = require "luci.http"
local uci = require"luci.model.uci".cursor()
local name = 'advancedplus'
module("luci.controller.advancedplus", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/advancedplus") then
		return
	end

	local page
	page = entry({"admin","system","advancedplus"},alias("admin","system","advancedplus","advancededit"),_("Advanced plus"),61)
	page.dependent = true
	page.acl_depends = { "luci-app-advancedplus" }
	
	entry({"admin","system","advancedplus","advancededit"},cbi("advancedplus/advancededit"),_("Advanced Edit"),10).leaf = true
	entry({"admin","system","advancedplus","advancedset"},cbi("advancedplus/advancedset"),_("Advanced Setting"),20).leaf = true
	entry({"admin","system","advancedplus","advancedipk"},cbi("advancedplus/advancedipk", {hideapplybtn=true, hidesavebtn=true, hideresetbtn=true}),_("Loading plugins"),30).leaf = true
	if nixio.fs.access('/www/luci-static/kucat/css/style.css') then
	    entry({"admin","system","advancedplus","kucatset"},cbi("advancedplus/kucatset"),_("KuCat Theme Config"),40).leaf = true
	    entry({"admin", "system","advancedplus","kucatupload"}, form("advancedplus/kucatupload"), _("Desktop background upload"), 80).leaf = true
	end
	if nixio.fs.access('/www/luci-static/argon/css/cascade.css') then
	    entry({"admin", "system", "advancedplus","argon-config"}, form("advancedplus/argon-config"), _("Argon Config"), 50).leaf = true
	end
	if nixio.fs.access('/www/luci-static/design/css/style.css') then
	    entry({"admin", "system",  "advancedplus","design-config"}, form("advancedplus/design-config"), _("Design Config"), 60).leaf = true
	end
	entry({"admin", "system","advancedplus","upload"}, form("advancedplus/upload"), _("Login Background Upload"), 70).leaf = true
	

	entry({"admin", "system", "advancedplus", "advancedrun"}, call("advanced_run"))
	entry({"admin", "system", "advancedplus", "check"}, call("act_check"))
end

function act_check()
	http.prepare_content("text/plain; charset=utf-8")
	local f=io.open("/tmp/advancedplus.log", "r+")
	local fdp=fs.readfile("/tmp/advancedpos") or 0
	f:seek("set",fdp)
	local a=f:read(2048000) or ""
	fdp=f:seek()
	fs.writefile("/tmp/advancedpos",tostring(fdp))
	f:close()
	http.write(a)
end

function advanced_run()
	local selectipk = luci.http.formvalue('select_ipk')
	luci.sys.exec("echo  'start' > /tmp/advancedplus.log&&echo  'start' > /tmp/advancedpos")
	uci:set(name, 'advancedplus', 'select_ipk', selectipk)
	uci:commit(name)
	fs.writefile("/tmp/advancedpos","0")
	http.prepare_content("application/json")
	http.write('')
	luci.sys.exec(string.format("bash /usr/bin/advancedplusipk " ..selectipk.. " > /tmp/advancedplus.log 2>&1 &" ))
end
