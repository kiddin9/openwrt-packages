-- Copyright 2018-2022 sirpdboy (herboy2008@gmail.com)
-- https://github.com/sirpdboy/luci-app-netdata

local n=require"nixio.fs"
local o=require"luci.util"

local i="/etc/netdata/netdata.conf"
local t,a,e
t=SimpleForm("netdata", translate("NetData"), translate("Netdata is high-fidelity infrastructure monitoring and troubleshooting.Open-source, free, preconfigured, opinionated, and always real-time.")..translate("</br>For specific usage, see:")..translate("<a href=\'https://github.com/sirpdboy/luci-app-netdata.git' target=\'_blank\'>GitHub @sirpdboy/luci-app-netdata </a>") )
t.reset=false
t.submit=false
a=t:section(SimpleSection,nil,translatef("The content of the config file in<code>/etc/netdata/netdata. conf</code>"))
e=a:option(TextValue,"_session")
e.rows=20
e.readonly=true
e.cfgvalue=function()
local e=n.readfile(i)or translate("File does not exist.")
return o.trim(e)~=""and e or translate("Empty file.")
end


return t
