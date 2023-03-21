m = Map("aliyundrive-fuse")
m.title = translate("AliyunDrive FUSE")
m.description = translate("<a href=\"https://github.com/messense/aliyundrive-fuse\" target=\"_blank\">Project GitHub URL</a>")

m:section(SimpleSection).template = "aliyundrive-fuse/aliyundrive-fuse_status"

e = m:section(TypedSection, "default")
e.anonymous = true

enable = e:option(Flag, "enable", translate("Enable"))
enable.rmempty = false

refresh_token = e:option(Value, "refresh_token", translate("Refresh Token"))
refresh_token.description = translate("<a href=\"https://github.com/messense/aliyundrive-webdav#%E8%8E%B7%E5%8F%96-refresh_token\" target=\"_blank\">How to get refresh token</a>")

mount_point = e:option(Value, "mount_point", translate("Mount Point"))
mount_point.default = "/mnt/aliyundrive"

read_buffer_size = e:option(Value, "read_buffer_size", translate("Read Buffer Size"))
read_buffer_size.default = "10485760"
read_buffer_size.datatype = "uinteger"

domain_id = e:option(Value, "domain_id", translate("Domain ID"))
domain_id.description = translate("Input domain_id option will use <a href=\"https://www.aliyun.com/product/storage/pds\" target=\"_blank\">Aliyun PDS</a> instead of <a href=\"https://www.aliyundrive.com\" target=\"_blank\">AliyunDrive</a>")

allow_other = e:option(Flag, "allow_other", translate("Allow Other users Access"))
allow_other.description = translate("Allow other users to access the drive, enable this if you share with samba")
allow_other.rmempty = false

debug = e:option(Flag, "debug", translate("Debug Mode"))
debug.rmempty = false

return m
