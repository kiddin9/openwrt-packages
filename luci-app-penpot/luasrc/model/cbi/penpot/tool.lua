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
o:value("create-user", "create-user")
o.default = "create-user"

local data = {}
o = s:option(Value, "email", "Email")
o.datatype = "string"
o.placeholder = "email@address"
o:depends("action", "create-user")

o = s:option(Value, "password", "Password")
o.password = true
o.datatype = "string"
o:depends("action", "create-user")

o = s:option(Value, "fullname", "Your Full Name")
o.datatype = "string"
o.placeholder = "Full Name"
o:depends("action", "create-user")

local t=Template("penpot/tool")
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
  if action == "create-user" then
    local email = m:get(section, "email")
    local password = m:get(section, "password")
    local fullname = m:get(section, "fullname")
    if email ~= nil and password ~= nil and fullname ~= nil then
      local cmd = string.format("/usr/libexec/istorec/penpot.sh %s %s %s %s", action, email, password, fullname)
      cmd = "/etc/init.d/tasks task_add penpot " .. luci.util.shellquote(cmd) .. " >/dev/null 2>&1"
      os.execute(cmd)
      t.show_log_taskid = "penpot"
    end
  end
end

return m

