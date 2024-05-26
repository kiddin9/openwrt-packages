
require("luci.tools.webadmin")

m = Map("guest-wifi", translate("Guest-wifi"))

s = m:section(TypedSection, "guest-wifi", translate("Config"))
s.description = translate("You can set guest wifi here. The wifi will be disconnected when enabling/disabling. When modifying the password, first disable the guest wifi, and then do the modification, save and apply. Finally check both Enable and Create, save and apply.")
s.anonymous = true 
s.addremove = false

o = s:option(Flag, "enable", translate("Enable"))
o.description = translate("Enable or disable guest wifi")
o.default = false
o.optional = false
o.rmempty = false

o = s:option(Flag, "create", translate("Create/Remove"))
o.description = translate("Check to create guest wifi when enabled, or check to remove guest wifi when disabled.")
o.default = false
o.optional = false
o.rmempty = false

o = s:option(ListValue, "device", translate("Define device"))
o.description = translate("Define device of guest wifi")
o:value("radio0", "radio0")
o:value("radio1", "radio1")
o:value("radio2", "radio2")
o.default = "radio0"

o = s:option(Value, "wifi_name", translate("Wifi name"))
o.description = translate("Define the name of guest wifi")
o.default = "Guest-WiFi"
o.rmempty = true

o = s:option(Value, "interface_name", translate("Interface name"))
o.description = translate("Define the interface name of guest wifi")
o.default = "guest"
o.rmempty = true

o = s:option(Value, "interface_ip", translate("Interface IP address"))
o.description = translate("Define IP address for guest wifi")
o.datatype = "ip4addr"
o.default ="192.168.4.1"

o = s:option(Value, "encryption", translate("Encryption"))
o.description = translate("Define encryption of guest wifi")
o:value("psk", "WPA-PSK")
o:value("psk2", "WPA2-PSK")
o:value("none", "No Encryption")
o.default = "psk2"
o.widget = "select"

o = s:option(Value, "passwd", translate("Password"))
o.description = translate("Define the password of guest wifi")
o.password = true
o.default = "guestnetwork"

o = s:option(ListValue, "isolate", translate("Isolation"))
o.description = translate("Enalbe or disable isolation")
o:value("1", translate("YES"))
o:value("0", translate("NO"))

o = s:option(Value, "start", translate("Start address"))
o.description = translate("Lowest leased address as offset from the network address")
o.default = "50"
o.rmempty = true

o = s:option(Value, "limit", translate("Client Limit"))
o.description = translate("Maximum number of leased addresses")
o.default = "200"
o.rmempty = true

o = s:option(Value, "leasetime", translate("DHCP lease time"))
o.description = translate("Expiry time of leased addresses, minimum is 2 minutes (2m)")
o.default = "1h"
o.rmempty = true

return m
