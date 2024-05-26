module "luci.pgyvpn.config"

--[[
	单独拿出来这些提示信息和 url 因为不通厂商会经常修改这些数据,之后直接修改此处的配置即可
--]]

URL_LINK = {
				-- text href
	CHECK_NET = {"查看网络", "https://pgy-api.oray.com/embed/authorization/redirect?sn="},
	SN_CODE = {"如何获取SN码","http://oray.cn/42D"},
	REGIST = {"注册帐号","http://oray.cn/42g"},
	OFFICIAL = {"官方网址","http://oray.cn/42d"},
	CONSOLE = {"云平台","http://oray.cn/42e"},
	HELP = {"使用帮助","http://oray.cn/42D"},
	MANAGER_NOT_ENOUGH = {"联系管理员","http://oray.cn/42k"},
	MANAGER_FORBIDEN_SERVICE = {"联系管理员","http://oray.cn/42F"},
	RENEW = {"立即续费","http://oray.cn/42s"},
	FORGET_PWD = {"忘记密码","https://console.oray.com/passport/forgot-password.html"}
}

VPN_ERROR = {
	-- ERR_USER_OR_PWD = {-1 , "帐号或密码错误", URL_LINK.MANAGER }, -- just do a test
	ERR_USER_OR_PWD = {-1 , "帐号或密码错误"},
	ERR_NO_USER_OR_PWD = {-2 , "请输入帐号或密码" },
	ERR_NOT_ENOUGH_MEMBER = {-3 , "组网成员数不足", URL_LINK.MANAGER_NOT_ENOUGH },
	ERR_SERVICE = {-9 , "帐号服务已禁用", URL_LINK.MANAGER_FORBIDEN_SERVICE},
	ERR_OUT_OF_SERVICE = {-5 , "组网服务已到期", URL_LINK.RENEW},
	ERR_AUTH = {-10 , "授权无效"},
	ERR_CONNECT_SERVER = {-11 , "链接服务器出错"}
}
