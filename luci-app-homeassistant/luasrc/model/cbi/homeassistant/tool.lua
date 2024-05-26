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
o:value("hacs-install", "hacs-install")
o.default = "hacs-install"

local t=Template("homeassistant/tool")
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
  if action == "hacs-install" then
    local cmd = string.format("/usr/libexec/istorec/homeassistant.sh %s", action)
    cmd = "/etc/init.d/tasks task_add homeassistant " .. luci.util.shellquote(cmd) .. " >/dev/null 2>&1"
    os.execute(cmd)
    t.show_log_taskid = "homeassistant"
  end
end

return m

