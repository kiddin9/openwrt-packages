--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local clouddrive2_model = require "luci.model.clouddrive2"
local m, s, o

m = taskd.docker_map("clouddrive2", "clouddrive2", "/usr/libexec/istorec/clouddrive2.sh",
	translate("CloudDrive2"),
	translate("CloudDrive is a powerful multi-cloud drive management tool with local mounting of cloud drives.")
		.. translate("Official website:") .. ' <a href=\"https://www.clouddrive2.com/\" target=\"_blank\">https://www.clouddrive2.com/</a>' .. '<br>'
		.. translate("Since mounting within the container requires the use of a special shared mount point, to avoid compatibility issues, only mounting to /mnt/CloudNAS is supported (mounting to other paths cannot be seen by the host). The shared mount point is automatically created by this plug-in, uninstalling the plug-in may cause the deployed CloudDrive container to fail to start or mount (iStoreOS is an exception, because /mnt is the shared mount point by default).") .. '<br>'
		.. translate("Disclaimer: This LuCI plug-in is developed by individuals. It only facilitates users to deploy CloudDrive containers (https://hub.docker.com/u/cloudnas) and has nothing to do with CloudDrive. Since CloudDrive is not open source software, although this plug-in has restricted its permissions to the greatest extent, it does not make any guarantees about the software content and services provided by CloudDrive. Use at your own risk!"))

s = m:section(SimpleSection, translate("Service Status"), translate("CloudDrive2 status:"))
s:append(Template("clouddrive2/status"))

s = m:section(TypedSection, "clouddrive2", translate("Setup"),
		translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "image", translate("Docker image"))
o.rmempty = false
o.datatype = "string"
o:value("default", translate("Default (cloudnas/clouddrive2)"))
o:value("cloudnas/clouddrive2-unstable", "cloudnas/clouddrive2-unstable")
o.default = "default"

o = s:option(Value, "port", translate("Port"))
o.default = "19798"
o.datatype = "port"

local blocks = clouddrive2_model.blocks()
local home = clouddrive2_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = clouddrive2_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "cache_path", translate("Temporary file path"), translate("Default use 'temp' in 'config path' if not set, please make sure there has enough space"))
o.datatype = "string"
local paths, default_path = clouddrive2_model.find_paths(blocks, home, "Caches")
for _, val in pairs(paths) do
  o:value(val, val)
end

o = s:option(Flag, "share_mnt", translate("Share /mnt"), translate("CloudDrive can read and write other mount points under /mnt for its synchronization or backup functions"))
o.default = 0

return m
