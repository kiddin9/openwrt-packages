local fs = require "nixio.fs"
local m = Map("nginx-manager",translate("Nginx Manager"), translate("A simple Nginx manager") .. [[<br /><a href="https://github.com/sundaqiang/openwrt-packages" target="_blank">Powered by sundaqiang</a>]])
s = m:section(TypedSection, "nginx", translate("Web site list"))
s.template = "nginx-manager/index"
s.addremove = true
s.anonymous = false
s:tab("general", translate("General Info"))
s:tab("server", translate("Configuration File"))
s:taboption("general", DummyValue, "name", translate("name"))
s:taboption("general", DummyValue, "filepath", translate("File Path"))
file=s:taboption("server", TextValue, "")
file.template = "cbi/tvalue"
file.rows = 25
file.wrap = "off"
file.rmempty = true

function s.create(self,section)
    path="/etc/nginx/conf.d/" .. section .. ".conf"
    fs.copyr("/etc/nginx/conf.d/templates", path)
    TypedSection.create(self,section)
    self.map:set(section, "name", section)
    self.map:set(section, "filepath", path)
    return true
end
function s.remove(self,section)
    path="/etc/nginx/conf.d/" .. section .. ".conf"
    fs.remove(path)
    TypedSection.remove(self,section)
end
function sync_value_to_file(value, file)
	value = value:gsub("\r\n?", "\n")
	local old_value = fs.readfile(file)
	if value ~= old_value then
		fs.writefile(file, value)
	end
end
function file.cfgvalue(self,section)
	return fs.readfile(self.map:get(section, "filepath")) or ""
end
function file.write(self, section, value)
	sync_value_to_file(value, self.map:get(section, "filepath"))
end
return m
