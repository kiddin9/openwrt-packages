#!/bin/sh

progress="$1"

#connect status
echo $progress >/tmp/orayboxvpn_connect_status

logger -t vpnprogress $progress

#99: 表示 链接中
# 1: 表示 已组网
# 0: 表示 未组网

# 显示登录页面
#4	-1: 表示 账号错误
#-2: 表示 帐号密码为空
#6	-3: 表示 成员数不足
#5	-4: 表示 登录失败
#2	-5: 表示 服务过期
#1026	-8: 表示 修改密码
#7	-9: 表示 服务被禁
#401 -10: 表示 授权被禁
#-1 -11: 表示 登录故障 这个要区别一下登录失败(登录成功后断开)


# 显示登录成功 未组网页面
#-1 -6: 表示 移除网络
#6	-7: 表示 状态关闭

# err_code=
# vpn_status=
# login_status=

if [ "$progress" == "connected" ] ;then ### 已组网
	vpn_status=1
elif [ "$progress" == "tryconnect" ] ;then
	logger -t vpnprogress $progress
elif [ "$progress" == "sn" ] ;then
	vpn_status=99
	uci set pgyvpn.base.login_status=1
	uci set pgyvpn.base.vpnid=$2
	uci set pgyvpn.base.vpnpwd=$3
elif [ "$progress" == "login_err" ] ;then
	vpn_status=0
	err_code=$2
	if [ "$err_code" == "4" ] ;then
		err_code=-1
	elif [ "$err_code" == "6" ] ;then
		err_code=-3
	elif [ "$err_code" == "5" ] ;then
		err_code=-4
	elif [ "$err_code" == "2" ] ;then
		err_code=-5
	elif [ "$err_code" == "7" ] ;then
		err_code=-9
	elif [ "$err_code" == "401" ] ;then
		err_code=-10
	elif [ "$err_code" == "403" ] ;then
		err_code=-10
	elif [ "$err_code" == "-1" ] ;then
		err_code=-11
	fi
	### login failed can't disabled vpn service

	if [ "$err_code" == "-11" ] ;then
		status=`uci get pgyvpn.base.login_status`
		logger -t errcode $status
		if [ "$status" != "1" ] ;then
			uci set pgyvpn.base.enable_status=0 ### 下回不启用
			/etc/init.d/pgyvpn stop > /dev/null
		fi
	elif [ "$err_code" != "-4" ] ;then
		uci set pgyvpn.base.enable_status=0 ### 下回不启用
		/etc/init.d/pgyvpn stop > /dev/null
	fi


	uci set pgyvpn.base.err_code=$err_code

elif [ "$progress" == "not_in_group" ] ;then ### 未组网
	## not_in_group is not a err
	vpn_status=0
	err_code=0
	uci set pgyvpn.base.login_status=1

elif [ "$progress" == "disconnected" ] ;then
	err_code=$2
	vpn_status=0
	if [ -n "$err_code" ] ;then
		vpn_status=0
		if [ "$err_code" == "-1" ] ;then
			err_code=-6
		elif [ "$err_code" == "6" ] ;then
			err_code=-7
		elif [ "$err_code" == "1026" ] ;then
			err_code=-8
		fi
		uci set pgyvpn.base.err_code=$err_code
	fi
fi

if [ -n "$vpn_status" ] ;then
	uci set pgyvpn.base.vpn_status=$vpn_status
fi

if [ "$err_code" == "-5" ] || [ "$err_code" == "-9" ] || [ "$err_code" == "-8" ] ;then
	uci set pgyvpn.base.login_status=0
	uci set pgyvpn.base.enable_status=0
fi

if [ "$vpn_status" == "1" ] || [ "$vpn_status" == "0" -a "$err_code" == "0" ] ;then
	uci set pgyvpn.base.login_status=1
	uci set pgyvpn.base.enable_status=1
fi

uci commit
