--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local docker = require "luci.docker"
local mtphotos_model = require "luci.model.mtphotos"
local m, s, o

m = taskd.docker_map("mtphotos", "mtphotos", "/usr/libexec/istorec/mtphotos.sh",
	translate("MTPhotos"),
	translate("MTPhotos is a photo manager, made by MTPhotos, Inc.")
		.. translate("Official website:") .. ' <a href=\"https://mtmt.tech/\" target=\"_blank\">https://mtmt.tech/</a>')

local dk = docker.new({socket_path="/var/run/docker.sock"})
local dockerd_running = dk:_ping().code == 200
local docker_info = dockerd_running and dk:info().body or {}
local docker_aspace = 0
if docker_info.DockerRootDir then
	local statvfs = nixio.fs.statvfs(docker_info.DockerRootDir)
	docker_aspace = statvfs and (statvfs.bavail * statvfs.bsize) or 0
end

s = m:section(SimpleSection, translate("Service Status"), translate("MTPhotos status:"))
s:append(Template("mtphotos/status"))

s = m:section(TypedSection, "main", translate("Setup"),
		(docker_aspace < 2147483648 and
		(translate("The free space of Docker is less than 2GB, which may cause the installation to fail.") 
		.. "<br>") or "") .. translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "port", translate("Port").."<b>*</b>")
o.default = "8063"
o.datatype = "port"
o:depends("hostnet", 0)

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("mtphotos/mt-photos:nodb-latest", "mtphotos/mt-photos:nodb-latest")
o:value("mtphotos/mt-photos:latest", "mtphotos/mt-photos:latest")
if "x86_64" == docker_info.Architecture then
  o.default = "mtphotos/mt-photos:latest"
else
	o:value("mtphotos/mt-photos:arm-latest", "mtphotos/mt-photos:arm-latest")
  o.default = "mtphotos/mt-photos:arm-latest"
end

local blocks = mtphotos_model.blocks()
local home = mtphotos_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = mtphotos_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val.."/Config", val.."/Config")
end
o.default = default_path.."/Config"

o = s:option(Value, "upload_path", translate("Upload path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

for _, val in pairs(paths) do
  o:value(val.."/Upload", val.."/Upload")
end
o.default = default_path.."/Upload"

return m
