local e=require"nixio.fs"
local t=require"luci.sys"
local t=luci.model.uci.cursor()
m=Map("advancedplus",translate("Advanced Edit"),translate("<font color=\"Red\"><strong>Configuration documents are directly edited unless you know what you are doing, please do not easily modify these configuration documents. Incorrect configuration may result in errors such as inability to power on</strong></font><br/>"))
m.apply_on_parse=true
s=m:section(TypedSection,"basic")
s.anonymous=true

if nixio.fs.access("/etc/dnsmasq.conf")then

s:tab("dnsmasqconf",translate("dnsmasq"),translate("This page is about configuration")..translate("/etc/dnsmasq.conf")..translate("Document content. Automatic restart takes effect after saving the application"))

conf=s:taboption("dnsmasqconf",Value,"dnsmasqconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/dnsmasq.conf")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/dnsmasq.conf",t)
if(luci.sys.call("cmp -s /tmp/dnsmasq.conf /etc/dnsmasq.conf")==1)then
e.writefile("/etc/dnsmasq.conf",t)
luci.sys.call("/etc/init.d/dnsmasq restart >/dev/null")
end
e.remove("/tmp/dnsmasq.conf")
end
end
end
if nixio.fs.access("/etc/config/network")then
s:tab("netwrokconf",translate("network"),translate("This page is about configuration")..translate("/etc/config/network")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("netwrokconf",Value,"netwrokconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/network")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/network",t)
if(luci.sys.call("cmp -s /tmp/network /etc/config/network")==1)then
e.writefile("/etc/config/network",t)
luci.sys.call("/etc/init.d/network restart >/dev/null")
end
e.remove("/tmp/network")
end
end
end
if nixio.fs.access("/etc/config/wireless")then
s:tab("wirelessconf",translate("wireless"), translate("This page is about configuration")..translate("/etc/config/wireless")..translate("Document content. Automatic restart takes effect after saving the application"))

conf=s:taboption("wirelessconf",Value,"wirelessconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/wireless")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/etc/config/wireless.tmp",t)
if(luci.sys.call("cmp -s /etc/config/wireless.tmp /etc/config/wireless")==1)then
e.writefile("/etc/config/wireless",t)
luci.sys.call("wifi reload >/dev/null &")
end
e.remove("/tmp//tmp/wireless.tmp")
end
end
end

if nixio.fs.access("/etc/hosts")then
s:tab("hostsconf",translate("hosts"), translate("This page is about configuration")..translate("/etc/hosts")..translate("Document content. Automatic restart takes effect after saving the application"))

conf=s:taboption("hostsconf",Value,"hostsconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/hosts")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/hosts.tmp",t)
if(luci.sys.call("cmp -s /tmp/hosts.tmp /etc/hosts")==1)then
e.writefile("/etc/hosts",t)
luci.sys.call("/etc/init.d/dnsmasq restart >/dev/null")
end
e.remove("/tmp/hosts.tmp")
end
end
end

if nixio.fs.access("/etc/config/arpbind")then
s:tab("arpbindconf",translate("arpbind"),translate("This page is about configuration")..translate("/etc/config/arpbind")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("arpbindconf",Value,"arpbindconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/arpbind")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/arpbind",t)
if(luci.sys.call("cmp -s /tmp/arpbind /etc/config/arpbind")==1)then
e.writefile("/etc/config/arpbind",t)
luci.sys.call("/etc/init.d/arpbind restart >/dev/null")
end
e.remove("/tmp/arpbind")
end
end
end

if nixio.fs.access("/etc/config/firewall")then
s:tab("firewallconf",translate("firewall"),translate("This page is about configuration")..translate("/etc/config/firewall")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("firewallconf",Value,"firewallconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/firewall")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/firewall",t)
if(luci.sys.call("cmp -s /tmp/firewall /etc/config/firewall")==1)then
e.writefile("/etc/config/firewall",t)
luci.sys.call("/etc/init.d/firewall restart >/dev/null")
end
e.remove("/tmp/firewall")
end
end
end

if nixio.fs.access("/etc/config/mwan3")then
s:tab("mwan3conf",translate("mwan3"),translate("This page is about configuration")..translate("/etc/config/mwan3")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("mwan3conf",Value,"mwan3conf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/mwan3")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/mwan3",t)
if(luci.sys.call("cmp -s /tmp/mwan3 /etc/config/mwan3")==1)then
e.writefile("/etc/config/mwan3",t)
luci.sys.call("/etc/init.d/mwan3 restart >/dev/null")
end
e.remove("/tmp/mwan3")
end
end
end

if nixio.fs.access("/etc/config/dhcp")then
s:tab("dhcpconf",translate("DHCP"),translate("This page is about configuration")..translate("/etc/config/dhcp")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("dhcpconf",Value,"dhcpconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/dhcp")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/dhcp",t)
if(luci.sys.call("cmp -s /tmp/dhcp /etc/config/dhcp")==1)then
e.writefile("/etc/config/dhcp",t)
luci.sys.call("/etc/init.d/network restart >/dev/null")
end
e.remove("/tmp/dhcp")
end
end
end

if nixio.fs.access("/etc/config/ddns")then
s:tab("ddnsconf",translate("DDNS"),translate("This page is about configuration")..translate("/etc/config/ddns")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("ddnsconf",Value,"ddnsconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/ddns")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/ddns",t)
if(luci.sys.call("cmp -s /tmp/ddns /etc/config/ddns")==1)then
e.writefile("/etc/config/ddns",t)
luci.sys.call("/etc/init.d/ddns restart >/dev/null")
end
e.remove("/tmp/ddns")
end
end
end

if nixio.fs.access("/etc/config/parentcontrol")then
s:tab("parentcontrolconf",translate("parentcontrol"),translate("This page is about configuration")..translate("/etc/config/parentcontrol")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("parentcontrolconf",Value,"parentcontrolconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/parentcontrol")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/parentcontrol",t)
if(luci.sys.call("cmp -s /tmp/parentcontrol /etc/config/parentcontrol")==1)then
e.writefile("/etc/config/parentcontrol",t)
luci.sys.call("/etc/init.d/parentcontrol restart >/dev/null")
end
e.remove("/tmp/parentcontrol")
end
end
end

if nixio.fs.access("/etc/config/autotimeset")then
s:tab("autotimesetconf",translate("autotimeset"),translate("This page is about configuration")..translate("/etc/config/autotimeset")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("autotimesetconf",Value,"autotimesetconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/autotimeset")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/autotimeset",t)
if(luci.sys.call("cmp -s /tmp/autotimeset /etc/config/autotimeset")==1)then
e.writefile("/etc/config/autotimeset",t)
luci.sys.call("/etc/init.d/autotimeset restart >/dev/null")
end
e.remove("/tmp/autotimeset")
end
end
end

if nixio.fs.access("/etc/config/wolplus")then
s:tab("wolplusconf",translate("wolplus"),translate("This page is about configuration")..translate("/etc/config/wolplus")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("wolplusconf",Value,"wolplusconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/wolplus")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/wolplus",t)
if(luci.sys.call("cmp -s /tmp/wolplus /etc/config/wolplus")==1)then
e.writefile("/etc/config/wolplus",t)
luci.sys.call("/etc/init.d/wolplus restart >/dev/null")
end
e.remove("/tmp/wolplus")
end
end
end

if nixio.fs.access("/etc/config/socat")then
s:tab("socatconf",translate("socat"),translate("This page is about configuration")..translate("/etc/config/socat")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("socatconf",Value,"socatconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/socat")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/socat",t)
if(luci.sys.call("cmp -s /tmp/socat /etc/config/socat")==1)then
e.writefile("/etc/config/socat",t)
luci.sys.call("/etc/init.d/socat restart >/dev/null")
end
e.remove("/tmp/socat")
end
end
end

if nixio.fs.access("/etc/config/nginx")then
s:tab("nginxconf",translate("NGINX"),translate("This page is about configuration")..translate("/etc/config/nginx")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("nginxconf",Value,"nginxconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/nginx")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/nginx",t)
if(luci.sys.call("cmp -s /tmp/nginx /etc/config/nginx")==1)then
e.writefile("/etc/config/nginx",t)
luci.sys.call("/etc/init.d/nginx restart >/dev/null")
end
e.remove("/tmp/nginx")
end
end
end

if nixio.fs.access("/etc/ddns-go/ddns-go-config.yaml")then
s:tab("ddnsgoconf",translate("DDNS-GO"),translate("This page is about configuration")..translate("ddns-go-config.yaml")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("ddnsgoconf",Value,"ddnsgoconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/ddns-go/ddns-go-config.yaml")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/ddnsgo",t)
if(luci.sys.call("cmp -s /tmp/ddns-go /etc/ddns-go/ddns-go-config.yaml")==1)then
e.writefile("/etc/ddns-go/ddns-go-config.yaml",t)
luci.sys.call("/etc/init.d/ddns-go restart >/dev/null")
end
e.remove("/tmp/ddnsgo")
end
end
end

if nixio.fs.access("/etc/config/smartdns")then
s:tab("smartdnsconf",translate("SMARTDNS"),translate("This page is about configuration")..translate("/etc/config/smartdns")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("smartdnsconf",Value,"smartdnsconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/smartdns")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/smartdns",t)
if(luci.sys.call("cmp -s /tmp/smartdns /etc/config/smartdns")==1)then
e.writefile("/etc/config/smartdns",t)
luci.sys.call("/etc/init.d/smartdns restart >/dev/null")
end
e.remove("/tmp/smartdns")
end
end
end

if nixio.fs.access("/etc/config/bypass")then
s:tab("bypassconf",translate("BYPASS"),translate("This page is about configuration")..translate("/etc/config/bypass")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("bypassconf",Value,"bypassconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/bypass")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/bypass",t)
if(luci.sys.call("cmp -s /tmp/bypass /etc/config/bypass")==1)then
e.writefile("/etc/config/bypass",t)
luci.sys.call("/etc/init.d/bypass restart >/dev/null")
end
e.remove("/tmp/bypass")
end
end
end

if nixio.fs.access("/etc/config/openclash")then
s:tab("openclashconf",translate("openclash"),translate("This page is about configuration")..translate("/etc/config/openclash")..translate("Document content. Automatic restart takes effect after saving the application"))
conf=s:taboption("openclashconf",Value,"openclashconf",nil,translate("The starting number symbol (#) or each line of the semicolon (;) is considered a comment; Remove (;) and enable the specified option."))
conf.template="cbi/tvalue"
conf.rows=20
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/openclash")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/openclash",t)
if(luci.sys.call("cmp -s /tmp/openclash /etc/config/openclash")==1)then
e.writefile("/etc/config/openclash",t)
luci.sys.call("/etc/init.d/openclash restart >/dev/null")
end
e.remove("/tmp/openclash")
end
end
end

return m
