--[[
LuCI - Lua Configuration Interface
]]--


require "luci.util"

local docker = require "luci.model.docker"
local dk = docker.new()

local container_name = "codeserver"

local m, s, o
local images, networks, container_info, res

res = dk.containers:inspect({name = container_name})
if res.code < 300 then
	container_info = res.body
else
	return
end

m=SimpleForm("Console", "", translate("Only works in LAN"))
m.submit = false
m.reset = false

local cmd_docker = luci.util.exec("command -v docker"):match("^.+docker") or nil
local cmd_ttyd = luci.util.exec("command -v ttyd"):match("^.+ttyd") or nil

if cmd_docker and cmd_ttyd and container_info.State.Status == "running" then
  local cmd = "/bin/bash"
  local uid

  s = m:section(SimpleSection)

  o = s:option(Value, "command", translate("Command"))
  o:value("/bin/sh", "/bin/sh")
  o:value("/bin/ash", "/bin/ash")
  o:value("/bin/bash", "/bin/bash")
  o.default = "/bin/bash"
  o.forcewrite = true
  o.write = function(self, section, value)
    cmd = value
  end

  o = s:option(Value, "uid", translate("UID"))
  o.forcewrite = true
  o.write = function(self, section, value)
    uid = value
  end

  o = s:option(Button, "connect")
  o.render = function(self, section, scope)
    self.inputstyle = "add"
    self.title = " "
    self.inputtitle = translate("Connect")
    Button.render(self, section, scope)
  end
  o.write = function(self, section)
    local cmd_docker = luci.util.exec("command -v docker"):match("^.+docker") or nil
    local cmd_ttyd = luci.util.exec("command -v ttyd"):match("^.+ttyd") or nil

    if not cmd_docker or not cmd_ttyd or cmd_docker:match("^%s+$") or cmd_ttyd:match("^%s+$")then
      return
    end

    local pid = luci.util.trim(luci.util.exec("netstat -lnpt | grep :7682 | grep ttyd | tr -s ' ' | cut -d ' ' -f7 | cut -d'/' -f1"))
    if pid and pid ~= "" then
      luci.util.exec("kill -9 " .. pid)
    end

    local hosts
    local uci = require "luci.model.uci".cursor()
    local remote = uci:get_bool("dockerd", "globals", "remote_endpoint") or false
    local host = nil
    local port = nil
    local socket = nil

    if remote then
      host = uci:get("dockerd", "globals", "remote_host") or nil
      port = uci:get("dockerd", "globals", "remote_port") or nil
    else
      socket = uci:get("dockerd", "globals", "socket_path") or "/var/run/docker.sock"
    end

    if remote and host and port then
      hosts = host .. ':'.. port
    elseif socket then
      hosts = socket
    else
      return
    end

    if uid and uid ~= "" then
      uid = "-u " .. uid
    else
      uid = ""
    end

    local start_cmd = string.format('%s -d 2 --once -p 7682 %s -H "unix://%s" exec -it %s %s %s&', cmd_ttyd, cmd_docker, hosts, uid, container_name, cmd)

    os.execute(start_cmd)

    o = s:option(DummyValue, "console")
    o.container_id = container_id
    o.template = "codeserver/console"
  end
end

return m
