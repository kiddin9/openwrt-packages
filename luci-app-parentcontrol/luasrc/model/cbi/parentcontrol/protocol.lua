local o = require "luci.sys"
local fs = require "nixio.fs"
local ipc = require "luci.ip"
local net = require "luci.model.network".init()
local sys = require "luci.sys"
local a, t, e
a = Map("parentcontrol", translate("Parent Control"), translate("<b><font color=\"green\">利用iptables来管控数据包过滤以禁止符合设定条件的用户连接互联网的工具软件。</font> </b></br>\
协议过滤：可以控制指定MAC机器是否使用指定协议端口，包括IPV4和IPV6，端口可以是连续端口范围用冒号分隔如5000:5100或多个端口用逗号分隔如：5100,5110,5001:5002,440:443</br>不指定MAC就是代表限制所有机器,星期用1-7表示，多个日期用：1,5表示星期一和星期五" ))

a.template = "parentcontrol/index"

t = a:section(TypedSection, "basic", translate(""))
t.anonymous = true

e = t:option(DummyValue, "parentcontrol_status", translate("当前状态"))
e.template = "parentcontrol/parentcontrol"
e.value = translate("Collecting data...")

e = t:option(Flag, "enabled", translate("开启"))
e.rmempty = false

e = t:option(ListValue, "control_mode",translate("管控强度"), translate("普通管控：管控国内网站端口，出国插件的国外端口无法管控！"))
e.rmempty = false
e:value("0", "普通管控")
e.default = "0"

t = a:section(TypedSection, "protocol", translate("协议过滤列表"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true

e = t:option(Value, 'remarks', translate('Remarks'))

e = t:option(Flag, "enable", translate("开启"))
e.rmempty = false
e.default = '1'

e = t:option(Value, "mac", translate("MAC地址<font color=\"green\">(留空为全部客户端)</font>"))
e.placeholder = "ALL"
e.rmempty = true
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)

e = t:option(ListValue, "proto", translate("<font color=\"gray\">端口协议</font>"))
e.rmempty = false
e.default = 'tcp'
e:value("tcp", translate("TCP"))
e:value("udp", translate("UDP"))
e:value("icmp", translate("ICMP"))

e = t:option(Value, "ports", translate("<font color=\"gray\">源端口</font>"))
e.rmempty = true

e = t:option(Value, "portd", translate("<font color=\"gray\">目的端口</font>"))
e:value("",translate("ICMP"))
e:value("80", "TCP-HTTP")
e:value("443", "TCP-HTTPS")
e:value("22", "TCP-SSH")
e:value("1723", "TCP-PPTP")
e:value("25", "TCP-SMTP")
e:value("110", "TCP-POP3")
e:value("21", "TCP-FTP21")
e:value("23", "TCP-TELNET")
e:value("53", "TCP-DNS53")
e:value("20", "UDP-FTP20")
e:value("1701", "UDP-L2TP")
e:value("69", "UDP-TFTP")
e:value("500", "UDP-IPSEC")
e:value("53", "UDP-DNS53")
e:value("161", "UDP-SNMP")
e.rmempty = true
    function validate_time(self, value, section)
        local hh, mm, ss
        hh, mm, ss = string.match (value, "^(%d?%d):(%d%d)$")
        hh = tonumber (hh)
        mm = tonumber (mm)
        if hh and mm and hh <= 23 and mm <= 59 then
            return value
        else
            return nil, "时间格式必须为 HH:MM 或者留空"
        end
    end
    
e = t:option(Value, "timestart", translate("起控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true

e = t:option(Value, "timeend", translate("停控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true

week=t:option(Value,"week",translate("Week Day"))
week.rmempty = true
week:value('*',translate("Everyday"))
week:value(7,translate("Sunday"))
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week.default='*'


return a



