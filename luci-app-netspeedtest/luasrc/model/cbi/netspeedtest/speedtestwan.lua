-- Copyright (C) 2020-2022  sirpdboy  <herboy2008@gmail.com> https://github.com/sirpdboy/netspeedtest
require("luci.util")
local o,t,e

o = Map("netspeedtest", "<font color='green'>" .. translate("Net Speedtest") .."</font>",translate( "Network speed diagnosis test (including intranet and extranet)<br/>For specific usage, see:") ..translate("<a href=\'https://github.com/sirpdboy/netspeedtest.git' target=\'_blank\'>GitHub @sirpdboy/netspeedtest</a>") )

t=o:section(TypedSection,"speedtestwan",translate("Broadband speed test"))
t.anonymous=true

e = t:option(ListValue, 'speedtest_cli', translate('client version selection'))
e:value("0",translate("ookla-speedtest-cli"))
e:value("1",translate("python3-speedtest-cli"))
e.default = "1"

e=t:option(Button, "restart", translate("speedtest.net Broadband speed test"))
e.inputtitle=translate("Click to execute")
e.template ='netspeedtest/speedtestwan'

return o
