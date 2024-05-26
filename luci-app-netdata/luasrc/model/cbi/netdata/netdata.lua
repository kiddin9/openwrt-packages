-- Copyright 2018-2022 sirpdboy (herboy2008@gmail.com)
-- https://github.com/sirpdboy/luci-app-netdata
require("luci.util")

local m, s ,o


m = Map("netdata", translate("NetData"), translate("Netdata is high-fidelity infrastructure monitoring and troubleshooting.Open-source, free, preconfigured, opinionated, and always real-time.")..translate("</br>For specific usage, see:")..translate("<a href=\'https://github.com/sirpdboy/luci-app-netdata.git' target=\'_blank\'>GitHub @sirpdboy/luci-app-netdata </a>") )
m:section(SimpleSection).template = "netdata_status"
s = m:section(TypedSection, "netdata", translate("Global Settings"))
s.addremove=false
s.anonymous=true

o=s:option(Flag,"enabled",translate("Enable"))
o.default=0

o=s:option(Value, "port",translate("Set the netdata access port"))
o.datatype="uinteger"
o.default=19999

m.apply_on_parse = true
m.on_after_apply = function(self,map)
  luci.sys.exec("/etc/init.d/netdata start")
  luci.http.redirect(luci.dispatcher.build_url("admin","status","netdata","setting"))
end

return m
