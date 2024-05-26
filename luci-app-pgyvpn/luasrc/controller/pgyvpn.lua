module("luci.controller.pgyvpn", package.seeall)

local cbi = require ('luci.model.uci').cursor()
local h = require 'luci.http'
local dsp = require 'luci.dispatcher'

-- vpn_status:
-- 99 vpn还在连接中
-- 1 已组网
-- 0 未组网

--	err_code:
-- -1 用户名密码错误
-- -2 用户名密码为空
--
-- login_status:
-- 1 登录成功 对应vpn_status >= 0 && ~= 99
-- 0 未登录	对应vpn_status < 0 or == 99

function check()
	local vpn_status = cbi:get("pgyvpn","base","vpn_status")
	local login_status = cbi:get("pgyvpn","base","login_status")
	local err_code = cbi:get("pgyvpn","base","err_code")

	-- logining
	if vpn_status == "99" then
		os.execute("sleep 1")
		if login_status == "0" then
			h.redirect(dsp.build_url("admin", "services", "check"))
		else
			h.redirect(dsp.build_url("admin", "services", "status"))
		end

	-- login err or not in group
	elseif vpn_status == "0" then

		-- no in group
		if err_code == "0" then
			h.redirect(dsp.build_url("admin", "services", "status"))
		end

		-- login err and redirecut to login page
		if err_code == "-1" or err_code == "-2" or err_code == "-3" or err_code == "-4" or err_code == "-5" or err_code == "-8" or err_code == "-9" or err_code == "-10"  then
			h.redirect(dsp.build_url("admin", "services", "pgyvpn"))
			os.execute("/etc/init.d/pgyvpn stop  > /dev/null");
		elseif	err_code == "-11" then
			h.redirect(dsp.build_url("admin", "services", "pgyvpn"))

		-- login err and redirecut to status page
		elseif err_code == "-6" or err_code == "-7" then
			h.redirect(dsp.build_url("admin", "services", "status"))

		else
			os.execute("sleep 1")
			h.redirect(dsp.build_url("admin", "services", "check"))
		end

	-- login success redirecut to status page
	elseif vpn_status == "1" then
		h.redirect(dsp.build_url("admin", "services", "status"))

	end
end

function login()
	local user = h.formvalue("user")
	local pwd = h.formvalue("pwd")
	require("luci.sys")
	cbi:section("pgyvpn", "base", "base", {
				user = user,
				pwd = pwd
				})

	cbi:set("pgyvpn","base","login_status","0")
	cbi:set("pgyvpn","base","vpn_status","0")
	cbi:set("pgyvpn","base","err_code","0")
	cbi:set("pgyvpn","base","enable_status","1")

	if  pwd == "" or user == "" then
		cbi:set("pgyvpn","base","vpn_status","0")
		cbi:set("pgyvpn","base","err_code","-2")
		cbi:save("pgyvpn")
		cbi:commit("pgyvpn")
		h.redirect(dsp.build_url("admin", "services", "pgyvpn"))
	else
		cbi:set("pgyvpn","base","vpn_status","99")
		cbi:set("pgyvpn","base","vpnid","")
		cbi:save("pgyvpn")
		cbi:commit("pgyvpn")
		os.execute("/etc/init.d/pgyvpn restart  > /dev/null");
		h.redirect(dsp.build_url("admin", "services", "check"))
	end
end

function logout()
	cbi:set("pgyvpn","base","login_status","0")
	cbi:set("pgyvpn","base","vpn_status","0")
	cbi:set("pgyvpn","base","err_code","0")
	cbi:set("pgyvpn","base","enable_status","0") -- 退出登录不启用
	cbi:save("pgyvpn")
	cbi:commit("pgyvpn")
	os.execute("/etc/init.d/pgyvpn stop  > /dev/null");
	h.redirect(dsp.build_url("admin", "services", "pgyvpn"))
end

function index()
	local page

	if not nixio.fs.access("/etc/config/pgyvpn") then
		return
	end

--1:  page with cbi
	-- page = entry(
	-- 	{"admin", "services", "pgyvpn"},
	-- 	cbi("pgyvpn",{hideapplybtn=false,hidesavebtn=true,hideresetbtn=true}),
	-- 	_("PGYVPN"),
	-- )
	-- page.dependent = true

--2:  page with htm
--
	local cbi = require ('luci.model.uci').cursor()
	local vpn_status = cbi:get("pgyvpn","base","vpn_status")
	local login_status = cbi:get("pgyvpn","base","login_status")

	--点击 服务->PGYVPN 时, 判断当前vpn登录情形 未登录则展示登录页面,已登录则展示vpn状态页面
	if login_status == "1" then
		entry({"admin", "services", "pgyvpn"}, template("pgyvpn/status"), "蒲公英智能组网", 12) -- vpn链接成功则显示vpn状态页面(组网/未组网)
	else
		entry({"admin", "services", "pgyvpn"}, template("pgyvpn/vpn"), "蒲公英智能组网", 12) -- 未链接vpn 则显示登录页面
	end

	-- 定义一些基本的入口
	entry({"admin", "services", "status"}, template("pgyvpn/status"), nil) -- 状态页面
	entry({"admin", "services", "login"}, call("login"), nil)  -- 登入
	entry({"admin", "services", "logout"}, call("logout"), nil) -- 登出
	entry({"admin", "services", "check"}, call("check"), nil) -- 检测vpn 链接状态
end
