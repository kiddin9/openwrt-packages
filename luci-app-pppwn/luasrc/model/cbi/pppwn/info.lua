local fs = require "nixio.fs"
local conffile = "/var/log/pppwn.log"

f = SimpleForm("logview")

t = f:field(TextValue, "conf")
t.rmempty = true
t.rows = 19
function t.cfgvalue()
	return fs.readfile(conffile) or ""
end
t.readonly = "readonly"

return f
