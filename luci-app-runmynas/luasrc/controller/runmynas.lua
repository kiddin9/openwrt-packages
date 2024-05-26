local util  = require "luci.util"
local http = require "luci.http"
local docker = require "luci.model.docker"
local iform = require "luci.iform"
local runmynas_model = require "luci.model.runmynas_disk"

module("luci.controller.runmynas", package.seeall)

function index()

  entry({"admin", "services", "runmynas"}, call("redirect_index"), _("RunMyNAS"), 30).dependent = true
  entry({"admin", "services", "runmynas", "pages"}, call("runmynas_index")).leaf = true
  entry({"admin", "services", "runmynas", "form"}, call("runmynas_form"))
  entry({"admin", "services", "runmynas", "submit"}, call("runmynas_submit"))

end

local appname = "runmynas"
local page_index = {"admin", "services", "runmynas", "pages"}

function redirect_index()
    http.redirect(luci.dispatcher.build_url(unpack(page_index)))
end

function runmynas_index()
    luci.template.render("runmynas/main", {prefix=luci.dispatcher.build_url(unpack(page_index))})
end

function runmynas_form()
    local error = ""
    local scope = ""
    local success = 0

    local blocks = runmynas_model.blocks()
    local home = runmynas_model.home()
    local paths, default_path = runmynas_model.find_paths(blocks, home, "Configs")
    local data = get_data(default_path)
    local result = {
        data = data,
        schema = get_schema(data, paths)
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

function get_schema(data, paths)
    local actions
    actions = {
      {
          name = "build",
          text = "运行",
          type = "apply",
      },
    } 
    local schema = {
      actions = actions,
      containers = get_containers(data, paths),
      description = "自定义你的 iStoreNAS，本插件只能运行在 X86 平台，可以去定制其他平台的固件。源码地址：<a href=\"https://github.com/linkease/iStoreNAS\" target=\"_blank\">https://github.com/linkease/iStoreNAS</a>",
      title = "RunMyNAS"
    }
    return schema
end

function get_containers(data, paths) 
    local containers = {
      main_container(data, paths)
    }
    return containers
end

function main_container(data, paths)
    local names = {}
    for k, v in pairs(paths) do 
      names[k] = v
    end
    local main_c2 = {
        properties = {
          {
            name = "download",
            required = true,
            title = "源码下载",
            type = "string",
            enum = {"github", "koolcenter"},
            enumNames = {"Github", "Koolcenter"}
          },
          {
            name = "target",
            required = true,
            title = "平台",
            type = "string",
            enum = {"x86_64", "rk35xx", "rk33xx"},
            enumNames = {"x86_64", "rk35xx", "rk33xx"}
          },
          {
            name = "path",
            required = true,
            title = "运行路径",
            type = "string",
            enum = paths,
            enumNames = names
          },
        },
        description = "请选择合适的平台运行：",
        title = "运行操作"
      }
      return main_c2
end

function get_data(default_path) 
  local uci = require "luci.model.uci".cursor()
  local target = uci:get_first(appname, appname, "target", "x86_64")
  local download = uci:get_first(appname, appname, "download", "github")
  local path = uci:get_first(appname, appname, "path", default_path)
  local data = {
    target = target,
    download = download,
    path = path,
  }
  return data
end

function runmynas_submit()
    local error = ""
    local scope = ""
    local success = 0
    local result
    
    local jsonc = require "luci.jsonc"
    local json_parse = jsonc.parse
    local content = http.content()
    local req = json_parse(content)
    result = runmynas(req)
    http.prepare_content("application/json")
    local resp = {
        error = error,
        scope = scope,
        success = success,
        result = result,
    }
    http.write_json(resp)
end

function runmynas(req)
  local download = req["download"]
  local target = req["target"]
  local path = req["path"]

  -- save config
  local uci = require "luci.model.uci".cursor()
  uci:tset(appname, "@"..appname.."[0]", {
    target = target or "x86_64",
    download = download or "github",
    path = path,
  })
  uci:save(appname)
  uci:commit(appname)

  local exec_cmd = string.format("/usr/libexec/istorec/runmynas.sh %s", req["$apply"])
  exec_cmd = "/etc/init.d/tasks task_add runmynas " .. luci.util.shellquote(exec_cmd)
  os.execute(exec_cmd .. " >/dev/null 2>&1")

  local result = {
    async = true,
    async_state = appname
  }
  return result
end

