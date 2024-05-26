local util  = require "luci.util"
local http = require "luci.http"
local lng = require "luci.i18n"
local jsonc = require "luci.jsonc"

module("luci.controller.systools", package.seeall)

function index()

  entry({"admin", "system", "systools"}, call("redirect_index"), _("System Convenient Tools"), 30).dependent = true
  entry({"admin", "system", "systools", "pages"}, call("systools_index")).leaf = true
  entry({"admin", "system", "systools", "form"}, call("systools_form"))
  entry({"admin", "system", "systools", "submit"}, call("systools_submit"))

end

local page_index = {"admin", "system", "systools", "pages"}

function redirect_index()
    http.redirect(luci.dispatcher.build_url(unpack(page_index)))
end

function systools_index()
    luci.template.render("systools/main", {prefix=luci.dispatcher.build_url(unpack(page_index))})
end

function systools_form()
    local error = ""
    local scope = ""
    local success = 0

    local data, extra = get_data()
    local result = {
        data = data,
        schema = get_schema(data, extra)
    } 
    local response = {
            error = error,
            scope = scope,
            success = success,
            result = result,
    }
    http.prepare_content("application/json")
    http.write_json(response)
end

function get_schema(data, extra)
  local actions
  actions = {
    {
        name = "install",
        text = lng.translate("Execute"),
        type = "apply",
    },
  }
  local schema = {
    actions = actions,
    containers = get_containers(data, extra),
    description = lng.translate("Some convenient tools which can fix some errors."),
    title = lng.translate("System Convenient Tools")
  }
  return schema
end

function get_containers(data, extra) 
    local containers = {
        main_container(data, extra)
    }
    return containers
end

function main_container(data, extra)
  local speedServerEnums = {}
  local speedServerNames = {}
  if data["tool"] == "speedtest" then
    speedServerEnums[#speedServerEnums+1] = "auto"
    speedServerNames[#speedServerNames+1] = "Auto Select"
    for key, val in pairs(extra.speedTestServers) do
      speedServerEnums[#speedServerEnums+1] = key
      speedServerNames[#speedServerNames+1] = val
    end
  end
  local main_c2 = {
      properties = {
        {
          name = "tool",
          required = true,
          title = "可执行操作",
          type = "string",
          enum = {"turn_off_ipv6", "full_ipv6", "half_ipv6", "reset_rom_pkgs", "qb_reset_password", "disk_power_mode", "speedtest", "openssl-aes256gcm", "openssl-chacha20-poly1305", "istore-reinstall", "disable-wandrop"},
          enumNames = {
            lng.translate("Turn off IPv6"), 
            lng.translate("Full IPv6"),
            lng.translate("Half IPv6 (Only Router)"),
            lng.translate("Reset rom pkgs"), 
            lng.translate("Reset qBittorrent Password"),
            lng.translate("HDD hibernation Status"),
            lng.translate("Run SpeedTest"),
            "openssl speed -evp aes-256-gcm",
            "openssl speed -evp chacha20-poly1305",
          }
        },
        {
          name = "speedTestServer",
          title = "Servers",
          type = "string",
          ["ui:hidden"] = "{{rootValue.tool !== 'speedtest' }}",
          enum = speedServerEnums,
          enumNames = speedServerNames
        },
      },
      description = lng.translate("Select the action to run:"),
      title = lng.translate("Actions")
    }
    return main_c2
end

function get_speedtest_servers()
  local vals = {}
  local f = io.popen("/usr/share/systools/speedtest-servers.run", "r")
  if f then
    local ret = f:read("*all")
    f:close()
    local obj = jsonc.parse(ret)
    if obj == nil then
      return vals
    end
    for _, val in pairs(obj["servers"]) do 
			if type(val["name"]) == "number" then
				vals[tostring(val["id"])] = string.format("%s,%s", val["location"], val["country"])
			else
				vals[tostring(val["id"])] = string.format("%s,%s,%s", val["name"], val["location"], val["country"])
			end
    end
  end
  return vals
end

function get_data() 
  local tool = luci.http.formvalue("tool")
  local extra = {}

  if not tool then
    local has = luci.http.formvalue("speedtest")
    if has and has ~= "" then
      tool = "speedtest"
    end
  end

  if tool then
    if tool == "speedtest" then
      extra["speedTestServers"] = get_speedtest_servers()
    end
  else
    tool = "turn_off_ipv6"
  end
  local data = {
    tool = tool,
    speedTestServer = "auto"
  }
  return data, extra
end

function systools_submit()
    local error = ""
    local scope = ""
    local success = 0
    local result
    
    local content = http.content()
    local req = jsonc.parse(content)
    if req["$apply"] == "install" then
      result = install_execute_systools(req)
    end
    http.prepare_content("application/json")
    local resp = {
        error = error,
        scope = scope,
        success = success,
        result = result,
    }
    http.write_json(resp)
end

function install_execute_systools(req)
  local cmd
  if req["tool"] == "speedtest" then
    cmd = string.format("/usr/libexec/istorec/systools.sh %s %s", req["tool"], req["speedTestServer"])
  else
    cmd = string.format("/usr/libexec/istorec/systools.sh %s", req["tool"])
  end
  cmd = "/etc/init.d/tasks task_add systools " .. luci.util.shellquote(cmd)
  os.execute(cmd .. " >/dev/null 2>&1")

  local result = {
    async = true,
    async_state = "systools"
  }
  return result
end

