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
o:value("gpu-passthrough", "gpu-passthrough")
o.default = "gpu-passthrough"

local t=Template("webvirtcloud/tool")
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
  if action == "gpu-passthrough" then
    local cmd = string.format("/usr/libexec/istorec/webvirtcloud.sh %s", action)
    cmd = "/etc/init.d/tasks task_add webvirtcloud " .. luci.util.shellquote(cmd) .. " >/dev/null 2>&1"
    os.execute(cmd)
    t.show_log_taskid = "webvirtcloud"
  end
end

return m

