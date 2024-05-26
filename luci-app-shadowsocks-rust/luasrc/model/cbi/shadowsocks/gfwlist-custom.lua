local fs = require "nixio.fs"
local conffile = "/etc/dnsmasq-extra.d/custom.conf"

f = SimpleForm("custom", translate("Be Careful!"), translate("Dnsmasq Config for Shadowsocks. This may CRASH DNSMASQ!"))

t = f:field(TextValue, "conf")
t.rmempty = true
t.rows = 30
function t.cfgvalue()
	return fs.readfile(conffile) or ""
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		if data.conf then
			fs.writefile(conffile, data.conf:gsub("\r\n", "\n"))
			luci.sys.call("/etc/init.d/dnsmasq-extra restart")
		end
	end
	return true
end

return f
