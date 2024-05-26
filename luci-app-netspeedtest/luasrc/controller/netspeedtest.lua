-- Copyright (C) 2020-2022  sirpdboy  <herboy2008@gmail.com> https://github.com/sirpdboy/netspeedtest

module("luci.controller.netspeedtest", package.seeall)
local http = require "luci.http"
local fs=require"nixio.fs"
local sys=require "luci.sys"
local uci = luci.model.uci.cursor()
name='netspeedtest'
function index()

    if not nixio.fs.access("/etc/config/netspeedtest") then return end

	local e = entry({"admin","network","netspeedtest"},alias("admin", "network", "netspeedtest", "speedtestlan"),_("Net Speedtest"),90)
	e.dependent = false
	e.acl_depends = { "luci-app-netspeedtest" }
	
	entry({"admin", "network", "netspeedtest", "speedtestlan"},cbi("netspeedtest/speedtestlan"),_("Lan Speedtest Web"),20).leaf = true
	entry({"admin", "network", "netspeedtest", "speedtestiperf3"},cbi("netspeedtest/speedtestiperf3", {hideapplybtn=true, hidesavebtn=true, hideresetbtn=true}),_("Lan Speedtest Iperf3"),30).leaf = true
        entry({"admin", "network", "netspeedtest", "speedtestwan"},cbi("netspeedtest/speedtestwan", {hideapplybtn=true, hidesavebtn=true, hideresetbtn=true}),_("Broadband speed test"), 40).leaf = true
        entry({"admin", "network", "netspeedtest", "speedtestport"},cbi("netspeedtest/speedtestport", {hideapplybtn=true, hidesavebtn=true, hideresetbtn=true}),_("Server Port Latency Test"), 50).leaf = true
        entry({"admin", "network", "netspeedtest", "log"}, form("netspeedtest/log"), _("Log"), 60).leaf = true
	entry({"admin", "network", "netspeedtest", "test_port"}, call("test_port"))
	entry({"admin", "network", "iperf3_status"}, call("iperf3_status"))
	entry({"admin", "network", "test_iperf0"}, post("test_iperf0"), nil).leaf = true
	entry({"admin", "network", "test_iperf1"}, post("test_iperf1"), nil).leaf = true
	entry({"admin", "network", "netspeedtest", "speedtestwanrun"}, call("speedtestwanrun"))
	entry({"admin", "network", "netspeedtest", "netcheck"}, call("netcheck"))
	entry({"admin", "network", "netspeedtest", "dellog"},call("dellog"))
        entry({"admin", "network", "netspeedtest", "getlog"},call("getlog"))
end

function netcheck()
	http.prepare_content("text/plain; charset=utf-8")
	local f=io.open("/etc/netspeedtest/netspeedtest.log", "r+")
	local fdp=fs.readfile("/etc/netspeedtest/netspeedtestpos") or 0
	f:seek("set",fdp)
	local a=f:read(2048000) or ""
	fdp=f:seek()
	fs.writefile("/etc/netspeedtest/netspeedtestpos",tostring(fdp))
	f:close()
	http.write(a)
end

function speedtestwanrun()
	local cli = luci.http.formvalue('cli')
	uci:set(name, 'speedtestwan', 'speedtest_cli', cli)
	uci:commit(name)
	fs.writefile("/etc/netspeedtest/netspeedtestpos","0")
	http.prepare_content("application/json")
	http.write('')
	sys.exec(string.format("/etc/init.d/netspeedtest wantest " ..cli.. " > /etc/netspeedtest/netspeedtest.log 2>&1 &" ))
end

function test_port()
	local e = {}
	local domain = luci.http.formvalue('sdomain')
	local port = luci.http.formvalue('sport')
	local ip=sys.exec("echo "..domain.." | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ || nslookup "..domain.." 2>/dev/null | grep Address | awk -F' ' '{print$NF}' | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ | sed -n 1p")
	ip=sys.exec("echo -n "..ip)
	e.ping = luci.sys.exec(string.format("echo -n $(tcping -q -c 1 -i 1 -t 2 -p %s %s 2>&1  | grep -o 'time=[0-9]*.[0-9]*' | awk -F '=' '{print $2}') 2>/dev/null", port, ip))
	e.type = "tcping"
	if e.ping=="" then
		e.ping=sys.call("echo -n $(ping -c 1 -W 1 %q 2>&1 | grep -o 'time=[0-9]*.[0-9]*' | awk -F '=' '{print $2}') 2>/dev/null" % ip)
		e.type = "ping"
	end
	if e.ping=="" then e.ping="0" end
	sys.exec(string.format('echo -ne "\n 【$(date)】 服务器：%s -- 端口：%s -- TCP延时：%s ms \n">> /var/log/netspeedtest.log',domain,port,e.ping))
	uci:set(name, 'speedtestport', 'sdomain', domain)
	uci:set(name, 'speedtestport', 'sport', port)
	uci:set(name, 'speedtestport', 'tcpspeed', e.ping.." ms")
	uci:commit(name)
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end


function iperf3_status()
	local e={}
	e.run=sys.call("busybox ps -w | grep iperf3 | grep -v grep >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function testout(cmd, addr)
		luci.http.prepare_content("text/plain")
		local util = io.popen(cmd)
		if util then
			while true do
				local ln = util:read("*l")
				if not ln then break end
				luci.http.write(ln)
				luci.http.write("\n")
			end
			util:close()
		end
end

function test_iperf0(addr)
       sys.call("pgrep -f unblockneteasemusic | xargs kill -9 >/dev/null 2>&1 ")
       sys.call("/etc/init.d/unblockneteasemusic stop ")
       sys.call("/etc/init.d/unblockmusic stop ")
       testout("iperf3 -s ", addr)
end

function test_iperf1(addr)
	sys.call("pgrep -f iperf3 | xargs kill -9 >/dev/null 2>&1 ")
	sys.call("/etc/init.d/unblockneteasemusic restart")
	sys.call("/etc/init.d/unblockmusic restart")
end

function dellog()
	fs.writefile("/var/log/netspeedtest.log","")
	http.prepare_content("application/json")
	http.write('')
end



function getlog()
	logfile="/var/log/netspeedtest.log"
	if not fs.access(logfile) then
		http.write("")
		return
	end
	local f=io.open(logfile,"r")
	local a=f:read("*a") or ""
	f:close()
	a=string.gsub(a,"\n$","")
	http.prepare_content("text/plain; charset=utf-8")
	http.write(a)
end

