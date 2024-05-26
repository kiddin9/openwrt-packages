--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local docker = require "luci.docker"
local htreader_model = require "luci.model.htreader"
local m, s, o

m = taskd.docker_map("htreader", "htreader", "/usr/libexec/istorec/htreader.sh",
	translate("HTReader"),
	translate("HTReader is book reader in web.")
		.. translate("Official website:") .. ' <a href=\"https://github.com/XIU2/Yuedu\" target=\"_blank\">https://github.com/XIU2/Yuedu</a>')

local dk = docker.new({socket_path="/var/run/docker.sock"})
local dockerd_running = dk:_ping().code == 200
local docker_info = dockerd_running and dk:info().body or {}
local docker_aspace = 0
if docker_info.DockerRootDir then
	local statvfs = nixio.fs.statvfs(docker_info.DockerRootDir)
	docker_aspace = statvfs and (statvfs.bavail * statvfs.bsize) or 0
end

s = m:section(SimpleSection, translate("Service Status"), translate("HTReader status:"))
s:append(Template("htreader/status"))

s = m:section(TypedSection, "main", translate("Setup"),
		(docker_aspace < 2147483648 and
		(translate("The free space of Docker is less than 2GB, which may cause the installation to fail.") 
		.. "<br>") or "") .. translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

o = s:option(Value, "port", translate("Port").."<b>*</b>")
o.default = "9060"
o.datatype = "port"

o = s:option(Flag, "multiuser", translate("Multiple user version"))
o.default = 0
o.rmempty = false

o = s:option(Value, "password", translate("password"))
o.datatype = "string"
o:depends("multiuser", 1)

o = s:option(Value, "active_code", translate("Active code"))
o.datatype = "string"
o:depends("multiuser", 1)

o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o.default = "hectorqin/reader"
o:value("hectorqin/reader", "hectorqin/reader")

local blocks = htreader_model.blocks()
local home = htreader_model.home()

o = s:option(Value, "config_path", translate("Config path").."<b>*</b>")
o.rmempty = false
o.datatype = "string"

local paths, default_path = htreader_model.find_paths(blocks, home, "Configs")
for _, val in pairs(paths) do
  o:value(val, val)
end
o.default = default_path

return m
