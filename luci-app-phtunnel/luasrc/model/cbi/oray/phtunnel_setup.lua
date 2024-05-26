m = Map("phtunnel")
m.reset = true

local s = m:section(NamedSection, "base", "base", translate("Base Setup"))

enabled = s:option(Flag, "enabled", translate("Enabled"))

enabled.rmempty = false

m.apply_on_parse = true
m.on_after_apply = function(self)
	io.popen("/etc/init.d/phtunnel restart")
end

return m
