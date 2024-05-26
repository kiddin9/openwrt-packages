--[[
	walkingsky
	tangxn_1@163.com
]]--

local sys = require "luci.sys"
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()

m = Map("wifidog", "wifidog执行参数配置","")

--if fs.access("/usr/bin/wifidog") then

	s = m:section(TypedSection, "wifidog", "wifidog配置")
	s.anonymous = true
	s.addremove = false
	
	
	s:tab("general", "通用配置")
	s:tab("servers", "认证服务器配置")
	s:tab("advanced", "高级配置")
	
	
	--通用配置
	wifi_enable = s:taboption("general",Flag, "wifidog_enable", translate("是否启用wifidog"),"打开或关闭wifidog")

	local t = io.popen("ifconfig | grep HWaddr | awk -F\" \" '{print $5}' | awk '$1~//{print;exit}' | sed 's/://g'")
	local temp = t:read("*all")	
	gatewayID = s:taboption("general",Value,"gateway_id","设备id（GatewayID）","默认为路由器MAC地址")
	gatewayID.default=temp
	
	gateway_interface = s:taboption("general",Value,"gateway_interface","内网接口","设置内网接口，默认'br-lan'")
	externalinterface = s:taboption("general",Value,"externalinterface","外网接口","WAN口接口，默认eth0.2")
	externalinterface.default = "eth0.2"
	
	
	
	--服务器配置项	

	server_hostname = s:taboption("servers",Value,"server_hostname","认证服务器：主机名","域名或ip")	
	server_httpport = s:taboption("servers",Value,"server_httpport","认证服务器：web服务端口","默认80端口")	
	server_path = s:taboption("servers",Value,"server_path","认证服务器：url路径","最后要加/，例如：'/'，'/wifidog/'；默认'/wifidog/'")
	server_sslAvailable = s:taboption("servers",Flag,"server_sslAvailable","启用SSL","默认不打开")
	server_sslport = s:taboption("servers",Value,"server_sslport","SSL端口","默认'443'")
	server_LoginScriptPathFragment = s:taboption("servers",Value,"server_LoginScriptPathFragment","服务器login接口脚本url路径段","默认'login/?'")
	server_PortalScriptPathFragment = s:taboption("servers",Value,"server_PortalScriptPathFragment","服务器portal接口脚本url路径段","默认'portal/?'")
	server_PingScriptPathFragment = s:taboption("servers",Value,"server_PingScriptPathFragment","服务器ping接口脚本url路径段","默认'ping/?'")
	server_AuthScriptPathFragment = s:taboption("servers",Value,"server_AuthScriptPathFragment","服务器auth接口脚本url路径段","默认'auth/?'")
	server_MsgScriptPathFragment = s:taboption("servers",Value,"server_MsgScriptPathFragment","服务器消息接口脚本url路径段","默认'gw_message.php?'")

	--gateway_hostname.default = "www.test.com"
	server_httpport.default = "80"
	server_path.default = "/wifidog/"
	server_sslAvailable.default = server_sslAvailable.disabled
	server_sslport.default = "443"
	server_LoginScriptPathFragment.default = "login/?"
	server_PortalScriptPathFragment.default = "portal/?"
	server_PingScriptPathFragment.default = "ping/?"
	server_AuthScriptPathFragment.default = "auth/?"
	server_MsgScriptPathFragment.default = "gw_message.php?"	
	
	--高级配置		
	
	--deamo_enable = s:taboption("advanced",Flag, "deamo_enable", "是否启用监护功能","检测wifidog意外退出后，重启wifidog")
	--deamo_enable:depends("wifidog_enable","1")
	gateway_port = s:taboption("advanced",Value, "gateway_port", "wifidog监听端口","默认'2060'")
	gateway_port.default = "2060"
	
	check_interval = s:taboption("advanced",Value, "check_interval", "和服务器通讯间隔，单位秒","默认'60'")
	check_interval.default = "60"
		
	client_timeout = s:taboption("advanced",Value, "client_timeout", "客户端掉线超时时间倍数，（通讯间隔的倍数）","默认'5'，即5倍的服务器通讯时间间隔后，仍然检测不到客户端，则自动下线该客户端")
	client_timeout.default = "5"
	
	s = m:section(TypedSection, "trustedmaclist", "MAC白名单列表","")
	s.anonymous = true
	s.addremove = true
	s.template = "cbi/tblsection"
	
	mac = s:option(Value, "mac", "mac地址")
	mac.rmempty  = false
	mac.datatype = "list(macaddr)"
	
	--sys.net.arptable(function(entry)
	luci.ip.neighbors(function(entry)
		mac:value(
			entry["HW address"],
			entry["HW address"] .. " (" .. entry["IP address"] .. ")"
		)
	end)
	
	s = m:section(TypedSection, "allowrule", "默认允许访问的服务","")
	s.anonymous = true
	s.addremove = true
	s.template = "cbi/tblsection"
	
	udp_tcp = s:option(ListValue, "protocol","协议")
	udp_tcp:value('tcp')
	udp_tcp:value('udp')
	--udp_tcp:value('icmp')
	
	ip = s:option(Value, "ip", "IP地址")
	ip.datatype = "ip4addr"
	ip.rmempty  = false
	
	port = s:option(Value,"port","端口号")
	port.rmempty = false
	port.datatype = "range(1,65535)"
	
--else
--	m.pageaction = false
--end


return m 

