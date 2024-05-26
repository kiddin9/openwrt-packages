-- Copyright 2020 Richard <xiaoqingfengatgm@gmail.com>
-- feed site : https://github.com/xiaoqingfengATGH/feeds-xiaoqingfeng
module("luci.controller.homeredirect", package.seeall)
local appname = "homeredirect"
local RUNLOG_DIR = "/tmp/hr"
local ucic = luci.model.uci.cursor()
local http = require "luci.http"

function index()
	
	entry({"admin", "services", "homeredirect", "show"}, call("show_menu")).leaf = true
    entry({"admin", "services", "homeredirect", "hide"}, call("hide_menu")).leaf = true
	
    if nixio.fs.access("/etc/config/homeredirect") and
        nixio.fs.access("/etc/config/homeredirect_show") then
            entry({"admin", "services", "homeredirect"},
			alias("admin", "services", "homeredirect", "settings"),
			_("Home Redirect"), 50).dependent = true
    end
	
    entry({"admin", "services", "homeredirect", "settings"},
          cbi("homeredirect/settings")).leaf = true
    entry({"admin", "services", "homeredirect", "status"}, call("status")).leaf =
        true
end

local function http_write_json(content)
	http.prepare_content("application/json")
	http.write_json(content or {code = 1})
end

function status()
    local e = {}
	e.enabled = ucic:get(appname, "@global[0]", "enabled")
	ucic:foreach(appname, "redirect", function(redirect)
		local state = -1
		local id = redirect['.name']
		local enabled = redirect['enabled']
		if enabled == "1" then
			local pid = luci.sys.exec("ps | grep socat | grep " .. RUNLOG_DIR .. "/" .. id .. " | sed '/grep/d' | awk -F ' ' '{print $1}'")
			if pid == "" then
				state = 0
			else
				state = tonumber(pid)
			end
		end
		e[id] = state
	end)
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function show_menu()
    luci.sys.call("touch /etc/config/homeredirect_show")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "homeredirect"))
end

function hide_menu()
    luci.sys.call("rm -rf /etc/config/homeredirect_show")
    luci.http.redirect(luci.dispatcher.build_url("admin", "status", "overview"))
end

