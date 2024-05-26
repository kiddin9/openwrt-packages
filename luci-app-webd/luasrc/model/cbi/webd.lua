m = Map("webd", translate("Webd Netdisk"),
translate("Webd - A lightweight self hosted netdisk")
.. [[  <a href="https://webd.cf/">]]
.. translate("Official Website")
.. [[</a>]]
)

m:section(SimpleSection).template  = "webd/webd_status"

s = m:section(TypedSection, "webd", translate("Basic Settings"), translate("Set the basic settings of Webd"))
s.anonymous = true

enable = s:option(Flag, "enable", translate("Enable"))
enable.default = 0

port = s:option(Value, "webd_port", translate("Listening Port"))
port.datatype = "port"
port.default = "9212"
port.rmempty = false

enable_ipv6 = s:option(Flag, "enable_ipv6", translate("Listen IPv6"), translatef("Listen both IPv4 and IPv6 Address"))
enable_ipv6.default = 0

root = s:option(Value, "webd_root", translate("Local Directory"), translatef("Directory of Webd"))
root.default = "/mnt"
root.rmempty = false

enable_recyclebin = s:option(Flag, "enable_recyclebin", translate("Recycle Bin"), translatef("Automatically create recycle bin directory"))
enable_recyclebin.default = 1

enable_anonymous = s:option(Flag, "enable_anonymous", translate("Enable Anonymous Access"), translatef("Anonymous access is allowed when enabled (Not Safe)"))
enable_anonymous.default = 0

anonymous_perm = s:option(MultiValue, "anonymous_perm", translate("Anonymous Permission"))
anonymous_perm:value("r", translate("Read files"))
anonymous_perm:value("l", translate("Obtain file list"))
anonymous_perm:value("u", translate("Upload files"))
anonymous_perm:value("m", translate("Remove files"))
anonymous_perm:value("S", translate("Show hidden files"))
anonymous_perm:value("D", translate("Append download attribute"))
anonymous_perm:value("T", translate("Play media"))
anonymous_perm:depends("enable_anonymous", "1")
anonymous_perm.description = translate("At least one permission must be choosed to allow anonymous access")

webd_bin = s:option(Value, "webd_bin", translate("Binary Path"), translatef("Webd binary Path"))
webd_bin.default = "/usr/bin/webd"
webd_bin.rmempty = false

webd_conf = s:option(Value, "webd_conf", translate("Config Path"), translatef("Webd config Path"))
webd_conf.default = "/etc/webd.conf"
webd_conf.rmempty = false

s = m:section(TypedSection, "users", translate("User Settings"), translate("Set the username, password and permissions. Maximum for 2 accounts"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

username = s:option(Value, "username", translate("Username"))
username.rmempty = false

password = s:option(Value, "password", translate("Password"))
password.rmempty = false
password.password=false

enable_read = s:option(Flag, "enable_read", translate("Read files"))
enable_read.default = 1

enable_read_list = s:option(Flag, "enable_read_list", translate("Obtain file list"))
enable_read_list.default = 1

enable_upload = s:option(Flag, "enable_upload", translate("Upload files"))
enable_upload.default = 1

enable_move = s:option(Flag, "enable_move", translate("Remove files"))
enable_move.default = 1

enable_showhide = s:option(Flag, "enable_showhide", translate("Show hidden files"))
enable_showhide.default = 0

enable_play = s:option(Flag, "enable_play", translate("Play media"))
enable_play.default = 1

return m
