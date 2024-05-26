require("luci.sys")

local uci = luci.model.uci.cursor()

m = Map('cloudflarespeedtest')
m.title = translate('Cloudflare Speed Test')
m.description = '<a href=\"https://github.com/mingxiaoyu/luci-app-cloudflarespeedtest\" target=\"_blank\">GitHub</a>'

-- [[ 基本设置 ]]--

s = m:section(NamedSection, 'global')
s.addremove = false
s.anonymous = true

o=s:option(Flag,"enabled",translate("Enabled"))
o.description = translate("Enabled scheduled task test Cloudflare IP")
o.rmempty=false
o.default = 0

o=s:option(Flag,"ipv6_enabled",translate("IPv6 Enabled"))
o.description = translate("Provides only one method, if IPv6 is enabled, IPv4 will not be tested")
o.default = 0
o.rmempty=false

o=s:option(Value,"speed",translate("Broadband speed"))
o.description =translate("100M broadband download speed is about 12M/s. It is not recommended to fill in an excessively large value, and it may run all the time.");
o.datatype ="uinteger" 
o.rmempty=false

o=s:option(Value,"custome_url",translate("Custome Url"))
o.description = translate("<a href=\"https://github.com/XIU2/CloudflareSpeedTest/issues/168\" target=\"_blank\">How to create</a>")
o.rmempty=false

o=s:option(Flag,"custome_cors_enabled",translate("Custome Cron Enabled"))
o.default = 0
o.rmempty=false

o = s:option(Value, "custome_cron", translate("Custome Cron"))
o:depends("custome_cors_enabled", 1)

hour = s:option(Value, "hour", translate("Hour"))
hour.datatype = "range(0,23)"
hour:depends("custome_cors_enabled", 0)

minute = s:option(Value, "minute", translate("Minute"))
minute.datatype = "range(0,59)"
minute:depends("custome_cors_enabled", 0)

o = s:option(ListValue, "proxy_mode", translate("Proxy Mode"))
o:value("nil", translate("HOLD"))
o.description = translate("during the speed testing, swith to which mode")
o:value("gfw", translate("GFW List"))
o:value("close", translate("CLOSE"))
o.default = "gfw"

o=s:option(Flag,"advanced",translate("Advanced"))
o.description = translate("Not recommended")
o.default = 0
o.rmempty=false

o = s:option(Value, "threads", translate("Thread"))
o.datatype ="uinteger" 
o.default = 200
o.rmempty=true
o:depends("advanced", 1)

o = s:option(Value, "tl", translate("Average Latency Cap"))
o.datatype ="uinteger" 
o.default = 200
o.rmempty=true
o:depends("advanced", 1)

o = s:option(Value, "tll", translate("Average Latency Lower Bound"))
o.datatype ="uinteger" 
o.default = 40
o.rmempty=true
o:depends("advanced", 1)

o = s:option(Value, "t", translate("Delayed speed measurement time"))
o.datatype ="uinteger" 
o.default = 4
o.rmempty=true
o:depends("advanced", 1)
 
o = s:option(Value, "dt", translate("Download speed test time"))
o.datatype ="uinteger" 
o.default = 10
o.rmempty=true
o:depends("advanced", 1)
 
o = s:option(Value, "dn", translate("Number of download speed tests"))
o.datatype ="uinteger" 
o.default = 1
o.rmempty=true
o:depends("advanced", 1)  

o = s:option(Flag, "dd", translate("Disable download speed test"))
o.default = 0
o.rmempty=true
o:depends("advanced", 1)  
 
o = s:option(Value, "tp", translate("Port"))
o.rmempty=true
o.default = 443
o.datatype ="port"
o:depends("advanced", 1)

o = s:option(DummyValue, '', '')
o.rawhtml = true
o.template = "cloudflarespeedtest/actions"

s = m:section(NamedSection, "servers", "section", translate("Third party applications settings"))

if nixio.fs.access("/etc/config/shadowsocksr") then
	s:tab("ssr", translate("Shadowsocksr Plus+"))	

	o=s:taboption("ssr", Flag, "ssr_enabled",translate("Shadowsocksr Plus+ Enabled"))
	o.rmempty=true	

	local ssr_server_table = {}
	uci:foreach("shadowsocksr", "servers", function(s)
		if s.alias then
			ssr_server_table[s[".name"]] = "[%s]:%s" % {string.upper(s.v2ray_protocol or s.type), s.alias}
		elseif s.server and s.server_port then
			ssr_server_table[s[".name"]] = "[%s]:%s:%s" % {string.upper(s.v2ray_protocol or s.type), s.server, s.server_port}
		end
	end)

	local ssr_key_table = {}
	for key, _ in pairs(ssr_server_table) do
		table.insert(ssr_key_table, key)
	end

	table.sort(ssr_key_table)

	o = s:taboption("ssr", DynamicList, "ssr_services",
			translate("Shadowsocksr Servers"),
			translate("Please select a service"))
			
	for _, key in pairs(ssr_key_table) do
		o:value(key, ssr_server_table[key])
	end
	o:depends("ssr_enabled", 1)
	o.forcewrite = true

end


if nixio.fs.access("/etc/config/passwall") then
	s:tab("passwalltab", translate("passwall"))

	o=s:taboption("passwalltab", Flag, "passwall_enabled",translate("Passwall Enabled"))
	o.rmempty=true	

	local passwall_server_table = {}
	uci:foreach("passwall", "nodes", function(s)
		if s.remarks then
			passwall_server_table[s[".name"]] = "[%s]:%s" % {string.upper(s.protocol or s.type), s.remarks}
		end
	end)

	local passwall_key_table = {}
	for key, _ in pairs(passwall_server_table) do
		table.insert(passwall_key_table, key)
	end

	table.sort(passwall_key_table)

	o = s:taboption("passwalltab", DynamicList, "passwall_services",
			translate("Passwall Servers"),
			translate("Please select a service"))
			
	for _, key in pairs(passwall_key_table) do
		o:value(key, passwall_server_table[key])
	end
	o:depends("passwall_enabled", 1)
	o.forcewrite = true

end

if nixio.fs.access("/etc/config/passwall2") then
	s:tab("passwall2tab", translate("passwall2"))

	o=s:taboption("passwall2tab", Flag, "passwall2_enabled",translate("PassWall2 Enabled"))
	o.rmempty=true	

	local passwall2_server_table = {}
	uci:foreach("passwall2", "nodes", function(s)
		if s.remarks then
			passwall2_server_table[s[".name"]] = "[%s]:%s" % {string.upper(s.protocol or s.type), s.remarks}
		end
	end)

	local passwall2_key_table = {}
	for key, _ in pairs(passwall2_server_table) do
		table.insert(passwall2_key_table, key)
	end

	table.sort(passwall2_key_table)

	o = s:taboption("passwall2tab", DynamicList, "passwall2_services",
			translate("Passwall2 Servers"),
			translate("Please select a service"))
			
	for _, key in pairs(passwall2_key_table) do
		o:value(key, passwall2_server_table[key])
	end
	o:depends("passwall2_enabled", 1)
	o.forcewrite = true

end

s:tab("bypasstab", translate("Bypass"))
if nixio.fs.access("/etc/config/bypass") then
	
	o=s:taboption("bypasstab", Flag, "bypass_enabled",translate("Bypass Enabled"))
	o.rmempty=true	

	local bypass_server_table = {}
	uci:foreach("bypass", "servers", function(s)
		if s.alias then
			bypass_server_table[s[".name"]] = "[%s]:%s" % {string.upper(s.protocol or s.type), s.alias}
		elseif s.server and s.server_port then
			bypass_server_table[s[".name"]] = "[%s]:%s:%s" % {string.upper(s.protocol or s.type), s.server, s.server_port}
		end
	end)

	local bypass_key_table = {}
	for key, _ in pairs(bypass_server_table) do
		table.insert(bypass_key_table, key)
	end

	table.sort(bypass_key_table)

	o = s:taboption("bypasstab", DynamicList, "bypass_services",
			translate("Bypass Servers"),
			translate("Please select a service"))
			
	for _, key in pairs(bypass_key_table) do
		o:value(key, bypass_server_table[key])
	end
	o:depends("bypass_enabled", 1)
	o.forcewrite = true

end

s:tab("vssrtab", translate("Vssr"))
if nixio.fs.access("/etc/config/vssr") then
	
	o=s:taboption("vssrtab", Flag, "vssr_enabled",translate("Vssr Enabled"))
	o.rmempty=true	

	local vssr_server_table = {}
	uci:foreach("vssr", "servers", function(s)
		if s.alias then
			vssr_server_table[s[".name"]] = "[%s]:%s" % {string.upper(s.protocol or s.type), s.alias}
		elseif s.server and s.server_port then
			vssr_server_table[s[".name"]] = "[%s]:%s:%s" % {string.upper(s.protocol or s.type), s.server, s.server_port}
		end
	end)

	local vssr_key_table = {}
	for key, _ in pairs(vssr_server_table) do
		table.insert(vssr_key_table, key)
	end

	table.sort(vssr_key_table)

	o = s:taboption("vssrtab", DynamicList, "vssr_services",
			translate("Vssr Servers"),
			translate("Please select a service"))
			
	for _, key in pairs(vssr_key_table) do
		o:value(key, vssr_server_table[key])
	end
	o:depends("vssr_enabled", 1)
	o.forcewrite = true

end

s:tab("dnstab", translate("DNS"))

o=s:taboption("dnstab", Flag, "DNS_enabled",translate("DNS Enabled"))

o=s:taboption("dnstab", ListValue, "DNS_type", translate("DNS Type"))
o:value("aliyu", translate("AliyuDNS"))
o:depends("DNS_enabled", 1)

o=s:taboption("dnstab", Value,"app_key",translate("Access Key ID"))
o.rmempty=true
o:depends("DNS_enabled", 1)
o=s:taboption("dnstab", Value,"app_secret",translate("Access Key Secret"))
o.rmempty=true
o:depends("DNS_enabled", 1)

o=s:taboption("dnstab", Value,"main_domain",translate("Main Domain"),translate("For example: test.github.com -> github.com"))
o.rmempty=true
o:depends("DNS_enabled", 1)
o=s:taboption("dnstab", DynamicList,"sub_domain",translate("Sub Domain"),translate("For example: test.github.com -> test"))
o.rmempty=true
o:depends("DNS_enabled", 1)

o=s:taboption("dnstab", ListValue, "line", translate("Lines"))
o:value("default", translate("default"))
o:value("telecom", translate("telecom"))
o:value("unicom", translate("unicom"))
o:value("mobile", translate("mobile"))
o:depends("DNS_enabled", 1)
o.default ="telecom"

s:tab("dnshost", translate("HOST"))
o=s:taboption("dnshost", Flag, "HOST_enabled",translate("HOST Enabled"))
o=s:taboption("dnshost", Value,"host_domain",translate("Domain"))
o.rmempty=true
o:depends("HOST_enabled", 1)

e=m:section(TypedSection,"global",translate("Best IP"))
e.anonymous=true
local a="/usr/share/cloudflarespeedtestresult.txt"
tvIPs=e:option(TextValue,"syipstext")
tvIPs.rows=8
tvIPs.readonly="readonly"
tvIPs.wrap="off"

function tvIPs.cfgvalue(e,e)
	sylogtext=""
	if a and nixio.fs.access(a) then
		sylogtext=luci.sys.exec("tail -n 100 %s"%a)
	end
	return sylogtext
end
tvIPs.write=function(e,e,e)
end

return m
