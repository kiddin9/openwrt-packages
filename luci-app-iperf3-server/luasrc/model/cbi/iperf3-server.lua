m = Map("iperf3-server", translate("iPerf3 Server"), translate("iPerf3 - The ultimate speed test tool for TCP, UDP and SCTP"))

m:section(SimpleSection).template = "iperf3-server/iperf3-server_status"

s = m:section(TypedSection, "iperf3-server", "")
s.addremove = false
s.anonymous = true

main_enable = s:option(Flag, "main_enable", translate("Enable"), translate("Enable iPerf3 Servers"))
main_enable.default = "0"
main_enable.rmempty = false

s = m:section(TypedSection, "servers", translate("Server Settings"), translate("Set up Multi-iPerf3 Servers"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

enable_server = s:option(Flag, "enable_server", translate("Enable"))
enable_server.default = "1"
enable_server.rmempty = false

port = s:option(Value, "port", translate("Port"))
port.datatype = "port"
port.default = "5201"
port.rmempty = false

delay = s:option(Value, "delay", translate("Start delay (Seconds)"))
delay.default = "0"
delay.datatype = "uinteger"
delay.rmempty = false

extra_options = s:option(Value, "extra_options", translate("Extra Options"))
extra_options.rmempty = true
extra_options.password= false

return m
