local d = require "luci.dispatcher"

m = Map("luci-app-openvpn-client", translate("Client List"))
m.apply_on_parse = true
m.redirect = d.build_url("admin", "vpn", "openvpn-client")

s = m:section(NamedSection, arg[1], "clients", "")
s.addremove = false
s.anonymous = true

o = s:option(Flag, "enabled", translate("Enabled"))
o.default = 1
o.rmempty = false

o = s:option(Value, "server", translate("Server IP/Host"))
o.rmempty = false

o = s:option(Value, "port", translate("Port"))
o.datatype = "port"
o.placeholder = "1194"
o.rmempty = false

o = s:option(ListValue, "proto", translate("Protocol"))
o:value("tcp", "TCP")
o:value("udp", "UDP")
o.rmempty = false

o = s:option(ListValue, "dev", translate("Type"))
o:value("tun", "TUN")
o:value("tap", "TAP")
o.rmempty = false

o = s:option(Flag, "lzo", translate("LZO compression"))
o.default = "1"
o.rmempty = false

o = s:option(Flag, "route_nopull", translate("No pull route"))
o.default = "1"
o.rmempty = false

o = s:option(DynamicList, "routes", translate("Static Routes"))
o.placeholder = "192.168.10.0/24"

o = s:option(ListValue, "auth", translate("Auth"))
o:value("", translate("None"))
o:value("user_pass", translate("User/Pass"))
o:value("tls_auth", "tls-auth")
o:value("tls_crypt", "tls-crypt")

o = s:option(Value, "username", translate("Username"))
o.placeholder = translate("Username")
o:depends("auth", "user_pass")

o = s:option(Value, "password", translate("Password"))
o.placeholder = translate("Password")
o:depends("auth", "user_pass")

o = s:option(TextValue, "tls_auth", "tls-auth")
o.datatype = "string"
o.rows = 3
o.wrap = "off"
o:depends("auth", "tls_auth")

o = s:option(TextValue, "tls_crypt", "tls-crypt")
o.datatype = "string"
o.rows = 3
o.wrap = "off"
o:depends("auth", "tls_crypt")

o = s:option(TextValue, "ca", "CA")
o.datatype = "string"
o.rows = 3
o.wrap = "off"
o.rmempty = false

o = s:option(TextValue, "cert", "Cert")
o.datatype = "string"
o.rows = 3
o.wrap = "off"

o = s:option(TextValue, "key", "Key")
o.datatype = "string"
o.rows = 3
o.wrap = "off"

o = s:option(ListValue, "proxy", translate("Proxy"))
o:value("", translate("None"))
o:value("socks", "Socks")
o:value("http", "HTTP")

o = s:option(Value, "proxy_server", translate("Proxy Server"))
o.placeholder = "127.0.0.1"
o.default = o.placeholder
o:depends("proxy", "socks")
o:depends("proxy", "http")

o = s:option(Value, "proxy_port", translate("Proxy Port"))
o.datatype = "port"
o.placeholder = "1080"
o.default = o.placeholder
o:depends("proxy", "socks")
o:depends("proxy", "http")

o = s:option(Value, "proxy_username", translate("Proxy Username"))
o.placeholder = translate("Username")
o:depends("proxy", "socks")
o:depends("proxy", "http")

o = s:option(Value, "proxy_password", translate("Proxy Password"))
o.placeholder = translate("Password")
o:depends("proxy", "socks")
o:depends("proxy", "http")

o = s:option(TextValue, "extra_config", translate("Extra Config"))
o.datatype = "string"
o.rows = 3
o.wrap = "off"

return m
