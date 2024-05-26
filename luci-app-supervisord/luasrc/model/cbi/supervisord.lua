local fs = require "nixio.fs"
local sys = require "luci.sys"

local m = Map("supervisord",translate("Supervisord"), translate("A golang development process management") .. [[<br /><br /><a href="https://github.com/sundaqiang/openwrt-packages" target="_blank">Powered by sundaqiang</a>]])
m:section(SimpleSection).template  = "supervisord/index"

s = m:section(TypedSection, "supervisord")
s.addremove = false
s.anonymous = true
s:tab("general", translate("General Settings"))
s:tab("advanced", translate("Configuration File"))
s:tab("list", translate("Task List"))
s:tab("log", translate("Log List"))

f = s:taboption("general", Flag, "enabled", translate("Enabled"))
f.rmempty = false
v = s:taboption("general", Value, "filepath", translate("File Path"))
v.rmempty = false
v = s:taboption("general", Flag, "usechinamirror", translate("Use China Mirror"))
v.rmempty = false
b = s:taboption("general", Button, "")
b.template = "supervisord/version"

file=s:taboption("advanced", TextValue, "")
file.template = "cbi/tvalue"
file.rows = 15
file.wrap = "off"
file.rmempty = false

l=s:taboption("list", DummyValue, "")
l.template = "supervisord/list"
l.list={}
index=1
for filelist in fs.dir("/etc/supervisord/program") do
    if filelist:find(".ini$") ~= nil then
        name=fs.readfile("/etc/supervisord/program/" .. filelist)
        l.list[index]={}
        l.list[index][1]=name:match("program:(%a+)")
        l.list[index][2]="/etc/supervisord/program/" .. filelist
        local cmd=name:match("directory=([%a%d%p ]+)") .. "/" .. name:match("getversions=([%a%d%p ]+)")
        l.list[index][3]=sys.exec(cmd)
        index=index+1
    end
end

g=s:taboption("log", DummyValue, "")
g.template = "supervisord/log"
g.list=l.list

function s.create(self,section)
    return TypedSection.create(self,section)
end
function s.remove(self,section)
    return TypedSection.remove(self,section)
end
function sync_value_to_file(self, section, value, file)
	value = value:gsub("\r\n?", "\n")
	local old_value = fs.readfile(file)
	if value ~= old_value then
		fs.writefile(file, value)
		self.map:set(section, "amend", "1")
	end
end
function file.cfgvalue(self,section)
	return fs.readfile("/etc/supervisord/supervisord.conf") or ""
end
function file.write(self, section, value)
	sync_value_to_file(self, section, value, "/etc/supervisord/supervisord.conf")
end
return m