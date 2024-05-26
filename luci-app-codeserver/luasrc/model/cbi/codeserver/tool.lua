--[[
LuCI - Lua Configuration Interface
]]--

local http = require 'luci.http'

m=SimpleForm("Tools")
m.submit = false
m.reset = false

s = m:section(SimpleSection)

o = s:option(Value, "action", translate("Action").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("git-config", "git-config")
o.default = "git-config"

local data = {}
o = s:option(Value, "username", "user.name")
o.datatype = "string"
o.placeholder = "username"
o:depends("action", "git-config")

o = s:option(Value, "email", "user.email")
o.datatype = "string"
o.placeholder = "email@address"
o:depends("action", "git-config")

local t=Template("codeserver/tool")
m:append(t)

local btn_do = s:option(Button, "_do")
btn_do.render = function(self, section, scope)
  self.inputstyle = "add"
  self.title = " "
  self.inputtitle = translate("Execute")
  Button.render(self, section, scope)
end

btn_do.write = function(self, section, value)
  local action = m:get(section, "action")
  if action == "git-config" then
    local user = m:get(section, "username")
    local email = m:get(section, "email")
    if user ~= nil and email ~= nil then
      local cmd = string.format("/usr/libexec/istorec/codeserver.sh %s %s %s", action, user, email)
      cmd = "/etc/init.d/tasks task_add codeserver " .. luci.util.shellquote(cmd) .. " >/dev/null 2>&1"
      os.execute(cmd)
      t.show_log_taskid = "codeserver"
    end
  end
end

return m

