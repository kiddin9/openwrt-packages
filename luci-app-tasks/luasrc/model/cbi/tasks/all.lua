--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local tasks = taskd.status()
local show_log_taskid
local m, s, o

local t=Template("tasks/all")

m = SimpleForm("taskd", 
	translate("All Tasks"), 
	translate("All submitted tasks, including system defined tasks"))
m.submit=false
m.reset=false

s = m:section(Table, tasks)
s.config = "tasks"

o = s:option(DummyValue, "_id", translate("ID"))
o.width="10%"
o.cfgvalue = function(self, section)
	return section
end

o = s:option(DummyValue, "_status", translate("Status"))
o.width="15%"
o.cfgvalue = function(self, section)
	local task = tasks[section]
	return task.running and translate("Running") or (translate("Stopped:") .. " " .. task.exit_code)
end

o = s:option(DummyValue, "_start", translate("Start Time"))
o.width="15%"
o.cfgvalue = function(self, section)
	local task = tasks[section]
	return os.date("%Y/%m/%d %H:%M:%S", task.start)
end
-- os.date("%Y/%m/%d %H:%M:%S", 1657163212)

local btn_log = s:option(Button, "_log", translate("Log"))
btn_log.inputstyle = "find"
btn_log.write = function(self, section, value)
	t.show_log_taskid = section
end

local btn_remove = s:option(Button, "_remove", translate("Remove"))
btn_remove.inputstyle = "remove"
btn_remove.forcewrite = true
btn_remove.write = function(self, section, value)
	local task_id = section
	os.execute("/etc/init.d/tasks task_del "..task_id.." >/dev/null 2>&1")
	tasks[task_id] = nil
end

m:append(t)

return m
