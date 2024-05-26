local m, s, o
m = Map("synology", "%s - %s " %{translate("黑群晖"), translate("硬件设置")},translate("<h3>黑群晖需要安装关机插件才可以实现关机。下载<a href='https://yuanfangblog.xyz/technology/227.html' target='_blank'>关机插件</a></h3>"))
--m.template = "synology/machine"--
m:section(SimpleSection).template = "synology/machine"

-- [[ Machine Settings ]]--
s = m:section(TypedSection, "machine", translate("虚拟机设置"))
s.anonymous = true


o = s:option(Value, "cpu", translate("CPU:"))
o.description = translate("默认调用本机如对参数了解可自定义，建议:Haswell.亲测成功")
o.default = "Haswell"
o.rmempty = false

o = s:option(Value, "m", translate("内存【单位G】:"))
o.datatype = "uinteger"
o.default = "2"
o.rmempty = false

o = s:option(Value, "smp", translate("SMP:"))
o.default = "2,sockets=2,cores=1,threads=1"
o.rmempty = false


o = s:option(Value, "hda", translate("HDA【硬盘1】:"))
o.default = ""
o.rmempty = true
o.description = translate("具体虚拟镜像文件或/dev/sda等")

o = s:option(Value, "hdb", translate("HDB【硬盘2】:"))
o.default = ""
o.rmempty = true

o = s:option(Value, "hdc", translate("HDC【硬盘3】:"))
o.default = ""
o.rmempty = true

o = s:option(Value, "hdd", translate("HDD【硬盘4】:"))
o.default = ""
o.rmempty = true

o = s:option(Value, "other", translate("其它参数:"))
o.default = ""
o.rmempty = true

o = s:option(Value, "vnc", translate("VNC端口:"))
o.datatype = "uinteger"
o.default = "1"
o.rmempty = false
o.description = translate("端口是从5900+n开始的,例如:1就是5901")

o = s:option(Value, "qmp", translate("QMP端口:"))
o.datatype = "uinteger"
o.default = "4444"
o.rmempty = false
o.description = translate("此处端口是主机和虚拟机沟通用的，比如发送关机命令，黑群晖需要安装关机插件")


o = s:option(Button, "create", translate("开机"))
o.inputstyle = "apply"
o.description = translate("开机")
o.write = function(self,section)
	luci.sys.call("/etc/init.d/synology start")
	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "synology", "machine"))
end


o = s:option(Button, "stop", translate("关机"))
o.inputstyle = "apply"
o.description = translate("关机")
o.description = translate("黑群机需要安装关机插件，否则正常关机是关不掉的需要强制关机")
o.write = function(self,section)
	luci.sys.call("/etc/init.d/synology stop")
	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "synology", "machine"))
end


o = s:option(Button, "enable", translate("开机启动"))
o.inputstyle = "apply"
o.description = translate("开机启动")
o.write = function(self,section)
	luci.sys.call("/etc/init.d/synology enable")
	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "synology", "machine"))
end

o = s:option(Button, "forceStop", translate("强制关机"))
o.inputstyle = "apply"
o.description = translate("强制关机")
o.write = function(self,section)
	luci.sys.call("/etc/init.d/synology forceStop")
	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "synology", "machine"))
end







return m
