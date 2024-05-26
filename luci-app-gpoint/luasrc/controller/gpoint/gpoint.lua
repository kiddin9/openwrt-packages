-------------------------------------------------------------
-- luci-app-gpoint. Gnss information dashboard for 3G/LTE dongle.
-------------------------------------------------------------
-- Copyright 2021-2022 Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0

local ubus = require("ubus")
local uci  = require("luci.model.uci")
local json = require("luci.jsonc")

module("luci.controller.gpoint.gpoint", package.seeall)

function index()
        entry({"admin", "services", "gpoint"}, alias ("admin","services", "gpoint", "map"), translate("GPoint"), 10).acl_depends={"unauthenticated"}
        entry({"admin", "services", "gpoint", "map"}, template("gpoint/overview"), translate("Overview"), 51).acl_depends={"unauthenticated"}
        entry({"admin", "services", "gpoint", "settings"}, cbi("gpoint/gpoint"), translate("Settings"), 52).acl_depends={"unauthenticated"}
        entry({"admin", "services", "gpoint", "action"}, call("gpoint_action"), nil).leaf = true
        entry({"admin", "services", "gpoint", "geopoint"}, call("get_geopoint"), nil).leaf = true
        entry({"admin", "services", "gpoint", "blackbox"}, call("get_blackbox"), nil).leaf = true
end

local serviceIsStop = {
        warning={
                app={true,"Service stop"},
                server={true,"Service stop"},
                filter={true,"Service stop"},
                locator={true,"Service stop"},
                kalman={true,"Service stop"}
        }
}

local serviceUbusFailed = {
        warning={
                app={true,"Ubus Failed"},
                server={true,"Loading..."},
                filter={true,"Loading..."},
                locator={true,"Loading..."},
                kalman ={true, "Loading..."}
        }
}

-- Overview JSON request
function get_geopoint()
        local sessionId = uci:get("gpoint", "service_settings", "sessionid")
        luci.http.prepare_content("application/json")
        local data
        if sessionId == "stop" then
                data = json.stringify(serviceIsStop)
        else
                local conn = ubus.connect()
                if conn then
                        local resp = conn:call("session", "list", {ubus_rpc_session = sessionId})
                        data = json.stringify(resp.data)
                        conn:close()
                else
                        data = json.stringify(serviceUbusFailed)
                end
                
        end
        luci.http.write(data)
end

-- BlackBox JSON request
function get_blackbox()
        local data = luci.sys.exec("cat /usr/share/gpoint/tmp/blackbox.json")
        luci.http.prepare_content("application/json")
        luci.http.write(data)
end

-- Settings init.d service 
function gpoint_action(name)
        local packageName = "gpoint"
        if name == "start" then
                luci.sys.init.start(packageName)
        elseif name == "action" then
                luci.util.exec("/etc/init.d/" .. packageName .. " reload")
        elseif name == "stop" then
                luci.sys.init.stop(packageName)
        elseif name == "enable" then
                luci.sys.init.enable(packageName)
        elseif name == "disable" then
                luci.sys.init.disable(packageName)
        end
        luci.http.prepare_content("text/plain")
        luci.http.write("0")
end
