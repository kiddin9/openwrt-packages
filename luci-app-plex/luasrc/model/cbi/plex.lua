--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local docker = require "luci.docker"
local plex_model = require "luci.model.plex"
local m, s, o

m = taskd.docker_map("plex", "plex", "/usr/libexec/istorec/plex.sh",
	translate("Plex"),
	translate("Plex is an streaming media service and a client–server media player platform, made by Plex, Inc.")
		.. translate("Official website:") .. ' <a href=\"https://www.plex.tv/\" target=\"_blank\">https://www.plex.tv/</a>')

local dk = docker.new({socket_path="/var/run/docker.sock"})
local dockerd_running = dk:_ping().code == 200
local docker_info = dockerd_running and dk:info().body or {}
local docker_aspace = 0
if docker_info.DockerRootDir then
	local statvfs = nixio.fs.statvfs(docker_info.DockerRootDir)
	docker_aspace = statvfs and (statvfs.bavail * statvfs.bsize) or 0
end

s = m:section(SimpleSection, translate("Service Status"), translate("Plex status:"))
s:append(Template("plex/status"))

s = m:section(TypedSection, "main", translate("Setup"),
		(docker_aspace < 2147483648 and
		(translate("The free space of Docker is less than 2GB, which may cause the installation to fail.") 
		.. "<br>") or "") .. translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Flag, "hostnet", translate("Host network"), translate("Plex running in host network, for DLNA application. Port is always 32400 if enabled"))
o.default = 0
o.rmempty = false

o = s:option(Value, "claim_token", translate("Plex Claim Token"), translatef("Obtain token from %s", "<a href=\"https://plex.tv/claim\" target=\"_blank\">Plex</a>"))
o.datatype = "string"

o = s:option(Value, "port", translate("Port").."<b>*</b>")
o.default = "32400"
o.datatype = "port"
o:depends("hostnet", 0)

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o.default = "linuxserver/plex:latest"
if "x86_64" == docker_info.Architecture then
	o:value("plexinc/pms-docker:latest", "plexinc/pms-docker:latest [x86_64]")
	o:value("plexinc/pms-docker:1.29.2.6364-6d72b0cf6", "plexinc/pms-docker:1.29.2.6364-6d72b0cf6 [x86_64]")
end
o:value("linuxserver/plex:latest", "linuxserver/plex:latest")
o:value("linuxserver/plex:1.29.2", "linuxserver/plex:1.29.2")

local blocks = plex_model.blocks()
local home = plex_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = plex_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

o = s:option(Value, "media_path", translate("Media path"), translatef("Not required, all disk will be mounted under %s", "<a href='/cgi-bin/luci/admin/services/linkease/file/?path=/root/mnt' target='_blank'>/mnt</a>"))
o.datatype = "string"

o = s:option(Value, "cache_path", translate("Transcode cache path").."<b>*</b>", translate("Please make sure there has enough space"))
o.rmempty = false
o.datatype = "string"
local paths, default_path = plex_model.find_paths(blocks, home, "Caches")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
