local uci = luci.model.uci.cursor()
local m, e

m = Map("pikpak-webdav")
m.title = translate("Pikpak WebDAV")
m.description = translate("<a href=\"https://github.com/ykxVK8yL5L/pikpak-webdav\" target=\"_blank\">Project GitHub URL</a>")

m:section(SimpleSection).template = "pikpak-webdav/pikpak-webdav_status"

e = m:section(TypedSection, "server")
e.anonymous = true

enable = e:option(Flag, "enable", translate("Enable"))
enable.rmempty = false


pikpak_user = e:option(Value, "pikpak_user", translate("Pikpak Username"))
pikpak_user.description = translate("Pikpak登陆用户名")

pikpak_password = e:option(Value, "pikpak_password", translate("Pikpak Password"))
pikpak_password.description = translate("Pikpak登陆密码")
pikpak_password.password = true


root = e:option(Value, "root", translate("Root Directory"))
root.description = translate("Restrict access to a folder of pikpak, defaults to / which means no restrictions")
root.default = "/"

host = e:option(Value, "host", translate("Host"))
host.default = "0.0.0.0"
host.datatype = "ipaddr"

port = e:option(Value, "port", translate("Port"))
port.default = "9867"
port.datatype = "port"

auth_user = e:option(Value, "auth_user", translate("Username"))
auth_password = e:option(Value, "auth_password", translate("Password"))
auth_password.password = true

read_buffer_size = e:option(Value, "read_buffer_size", translate("Read Buffer Size"))
read_buffer_size.default = "10485760"
read_buffer_size.datatype = "uinteger"

upload_buffer_size = e:option(Value, "upload_buffer_size", translate("Write Buffer Size"))
upload_buffer_size.default = "16777216"
upload_buffer_size.datatype = "uinteger"



cache_size = e:option(Value, "cache_size", translate("Cache Size"))
cache_size.default = "1000"
cache_size.datatype = "uinteger"

cache_ttl = e:option(Value, "cache_ttl", translate("Cache Expiration Time (seconds)"))
cache_ttl.default = "600"
cache_ttl.datatype = "uinteger"


cache_size = e:option(Value, "proxy_url", translate("Proxy Url"))
cache_size.default = ""


-- no_trash = e:option(Flag, "no_trash", translate("Delete file permanently instead of trashing"))
-- no_trash.rmempty = false


debug = e:option(Flag, "debug", translate("Debug Mode"))
debug.rmempty = false

return m
