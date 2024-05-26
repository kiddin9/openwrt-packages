local util  = require "luci.util"
local http = require "luci.http"
local docker = require "luci.model.docker"
local iform = require "luci.iform"

module("luci.controller.ubuntu", package.seeall)

function index()

  entry({"admin", "services", "ubuntu"}, call("redirect_index"), _("Ubuntu"), 30).dependent = true
  entry({"admin", "services", "ubuntu", "pages"}, call("ubuntu_index")).leaf = true
  entry({"admin", "services", "ubuntu", "form"}, call("ubuntu_form"))
  entry({"admin", "services", "ubuntu", "submit"}, call("ubuntu_submit"))

end

local appname = "ubuntu"
local page_index = {"admin", "services", "ubuntu", "pages"}

function redirect_index()
    http.redirect(luci.dispatcher.build_url(unpack(page_index)))
end

function ubuntu_index()
    luci.template.render("ubuntu/main", {prefix=luci.dispatcher.build_url(unpack(page_index))})
end

function ubuntu_form()
    local error = ""
    local scope = ""
    local success = 0

    local data = get_data()
    local result = {
        data = data,
        schema = get_schema(data)
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

function get_schema(data)
  local actions
  if data.container_install then
    actions = {
      {
          name = "restart",
          text = "重启",
          type = "apply",
      },
      {
          name = "upgrade",
          text = "更新",
          type = "apply",
      },
      {
          name = "remove",
          text = "删除",
          type = "apply",
      },
    } 
  else
    actions = {
      {
          name = "install",
          text = "安装",
          type = "apply",
      },
    }
  end
    local schema = {
      actions = actions,
      containers = get_containers(data),
      description = "带 Web 远程桌面的 Docker 高性能版 Ubuntu。默认<用户名:kasm_user 密码:password> 访问官网 <a href=\"https://www.kasmweb.com/\" target=\"_blank\">https://www.kasmweb.com/</a>",
      title = "Ubuntu"
    }
    return schema
end

function get_containers(data) 
    local containers = {
        status_container(data),
        main_container(data)
    }
    return containers
end

function status_container(data)
  local status_value

  if data.container_install then
    status_value = "Ubuntu 运行中"
  else
    status_value = "Ubuntu 未运行"
  end

  local status_c1 = {
    labels = {
      {
        key = "状态：",
        value = status_value
      },
      {
        key = "访问：",
        value = ""
        -- value = "'<a href=\"https://' + location.host + ':6901\" target=\"_blank\">Ubuntu 桌面</a>'"
      }

    },
    description = "访问链接是一个自签名的 https，需要浏览器同意才能访问！",
    title = "服务状态"
  }
  return status_c1
end

function main_container(data)
    local main_c2 = {
        properties = {
          {
            name = "port",
            required = true,
            title = "端口",
            type = "string"
          },
          {
            name = "password",
            required = true,
            title = "密码",
            type = "string"
          },
          {
            name = "version",
            required = true,
            title = "安装版本",
            type = "string",
            enum = {"standard", "full"},
            enumNames = {"Standard Version", "Full Version"}
          },
        },
        description = "请选择合适的版本进行安装：",
        title = "服务操作"
      }
      return main_c2
end

function get_data() 
  local uci = require "luci.model.uci".cursor()
  local docker_path = util.exec("which docker")
  local docker_install = (string.len(docker_path) > 0)
  -- docker ps -aqf
  local container_id = util.trim(util.exec("docker ps -qf 'name="..appname.."'"))
  local container_install = (string.len(container_id) > 0)
  local port = tonumber(uci:get_first(appname, appname, "port", "6901"))
  local data = {
    port = port,
    user_name = "kasm_user",
    password = uci:get_first(appname, appname, "password", ""),
    version = uci:get_first(appname, appname, "version", "standard"),
    container_install = container_install
  }
  return data
end

function ubuntu_submit()
    local error = ""
    local scope = ""
    local success = 0
    local result
    
    local jsonc = require "luci.jsonc"
    local json_parse = jsonc.parse
    local content = http.content()
    local req = json_parse(content)
    if req["$apply"] == "upgrade" then
      result = install_upgrade_ubuntu(req)
    elseif req["$apply"] == "install" then 
      result = install_upgrade_ubuntu(req)
    elseif req["$apply"] == "restart" then 
      result = restart_ubuntu(req)
    else
      result = delete_ubuntu()
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

function install_upgrade_ubuntu(req)
  local password = req["password"]
  local port = req["port"]
  local version = req["version"]

  -- save config
  local uci = require "luci.model.uci".cursor()
  uci:tset(appname, "@"..appname.."[0]", {
    password = password or "password",
    port = port or "6901",
    version = version or "standard",
  })
  uci:save(appname)
  uci:commit(appname)

  local exec_cmd = string.format("/usr/libexec/istorec/ubuntu.sh %s", req["$apply"])
  exec_cmd = "/etc/init.d/tasks task_add ubuntu " .. luci.util.shellquote(exec_cmd)
  os.execute(exec_cmd .. " >/dev/null 2>&1")

  local result = {
    async = true,
    async_state = appname
  }
  return result
end

function delete_ubuntu()
  local log = iform.exec_to_log("docker rm -f ubuntu")
  local result = {
    async = false,
    log = log
  }
  return result
end

function restart_ubuntu()
  local log = iform.exec_to_log("docker restart ubuntu")
  local result = {
    async = false,
    log = log
  }
  return result
end

