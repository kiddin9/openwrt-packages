--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local docker = require "luci.docker"
local m, s, o

m = taskd.docker_map("ittools", "ittools", "/usr/libexec/istorec/ittools.sh",
	translate("ITTools"),
	translate("ITTools is useful tools for developer and people working in IT.")
		.. translate("Official website:") .. ' <a href=\"https://it-tools.tech/\" target=\"_blank\">https://it-tools.tech/</a>')

local dk = docker.new({socket_path="/var/run/docker.sock"})
local dockerd_running = dk:_ping().code == 200
local docker_info = dockerd_running and dk:info().body or {}
local docker_aspace = 0
if docker_info.DockerRootDir then
	local statvfs = nixio.fs.statvfs(docker_info.DockerRootDir)
	docker_aspace = statvfs and (statvfs.bavail * statvfs.bsize) or 0
end

s = m:section(SimpleSection, translate("Service Status"), translate("ITTools status:"))
s:append(Template("ittools/status"))

s = m:section(TypedSection, "main", translate("Setup"),
		(docker_aspace < 2147483648 and
		(translate("The free space of Docker is less than 2GB, which may cause the installation to fail.") 
		.. "<br>") or "") .. translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "port", translate("Port").."<b>*</b>")
o.default = "9070"
o.datatype = "port"
o:depends("hostnet", 0)

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o.default = "corentinth/it-tools:latest"
o:value("corentinth/it-tools:latest", "corentinth/it-tools:latest")
o:value("ghcr.io/corentinth/it-tools:latest", "ghcr.io/corentinth/it-tools:latest")

return m
