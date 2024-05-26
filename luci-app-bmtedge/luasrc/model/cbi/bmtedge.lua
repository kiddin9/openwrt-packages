--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local bmtedge_model = require "luci.model.bmtedge"
local m, s, o

m = taskd.docker_map("bmtedge", "bmtedge", "/usr/libexec/istorec/bmtedge.sh",
	translate("BlueMountain Edge"),
	"蓝山云-流量宝由蓝山联合金山云推出的一款镜像软件，通过简单安装后可快速加入蓝山的边缘计算生态，在线共享带宽即可赚钱，每月可获取一定的现金回报！了解更多，请登录「<a href=\"https://www.bmtcloud.com.cn\" target=\"_blank\" >蓝山云官网</a>」并查看<a href=\"https://doc.linkease.com/zh/guide/istoreos/software/bmtedge.html\" target=\"_blank\">「教程」</a>")

s = m:section(SimpleSection, translate("Service Status"), translate("BlueMountain Edge status:"), "注意网心云会以超级权限运行！")
s:append(Template("bmtedge/status"))

s = m:section(TypedSection, "bmtedge", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

local default_image = bmtedge_model.default_image()
o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("jinshanyun/jinshan-x86_64", "jinshanyun/jinshan-x86_64")
o:value("jinshanyun/jinshan-arm64", "jinshanyun/jinshan-arm64")
o:value("jinshanyun/jinshan-x86_64:v1.2", "jinshanyun/jinshan-x86_64:v1.2")
o:value("jinshanyun/jinshan-arm64:v2.2", "jinshanyun/jinshan-arm64:v2.2")
o.default = default_image

local default_uid = bmtedge_model.default_uid()
o = s:option(Value, "uid", translate("UID").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value(default_uid, default_uid)
o.default = default_uid

local blks = bmtedge_model.blocks()
local dir
o = s:option(Value, "cache_path", translate("Cache path").."<b>*</b>", "请选择合适的存储位置进行安装，安装位置容量越大，收益越高。安装后请勿轻易改动")
o.rmempty = false
o.datatype = "string"
for _, dir in pairs(blks) do
	dir = dir .. "/bmtedge1"
	o:value(dir, dir)
end
if #blks > 0 then
    o.default = blks[1] .. "/bmtedge1"
end

return m
