--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local docker = require "luci.docker"
local drawio_model = require "luci.model.drawio"
local m, s, o

m = taskd.docker_map("drawio", "drawio", "/usr/libexec/istorec/drawio.sh",
	translate("DrawIO"),
	translate("DrawIO is a draw.io is a client-side editor for general diagramming and whiteboarding.")
		.. translate("Official website:") .. ' <a href=\"https://www.diagrams.net/\" target=\"_blank\">https://www.diagrams.net/</a>')

local dk = docker.new({socket_path="/var/run/docker.sock"})
local dockerd_running = dk:_ping().code == 200
local docker_info = dockerd_running and dk:info().body or {}
local docker_aspace = 0
if docker_info.DockerRootDir then
	local statvfs = nixio.fs.statvfs(docker_info.DockerRootDir)
	docker_aspace = statvfs and (statvfs.bavail * statvfs.bsize) or 0
end

s = m:section(SimpleSection, translate("Service Status"), translate("DrawIO status:"))
s:append(Template("drawio/status"))

s = m:section(TypedSection, "main", translate("Setup"),
		(docker_aspace < 2147483648 and
		(translate("The free space of Docker is less than 2GB, which may cause the installation to fail.") 
		.. "<br>") or "") .. translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "port", translate("Port").."<b>*</b>")
o.default = "8091"
o.datatype = "port"

local blocks = drawio_model.blocks()
local home = drawio_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = drawio_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
