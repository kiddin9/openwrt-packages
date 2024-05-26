--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local wxedge_model = require "luci.model.wxedge"
local m, s, o

m = taskd.docker_map("wxedge", "wxedge", "/usr/libexec/istorec/wxedge.sh",
	translate("Onething Edge"),
	"「网心云-容器魔方」由网心云推出的一款 docker 容器镜像软件，通过在简单安装后即可快速加入网心云共享计算生态网络，用户可根据每日的贡献量获得相应的现金收益回报。了解更多，请登录「<a href=\"https://www.onethingcloud.com/\" target=\"_blank\" >网心云官网</a>」并查看<a href=\"https://doc.linkease.com/zh/guide/istoreos/software/wxedge.html\" target=\"_blank\">「教程」</a>")

s = m:section(SimpleSection, translate("Service Status"), translate("Onething Edge status:"), "注意网心云会以超级权限运行！")
s:append(Template("wxedge/status"))

s = m:section(TypedSection, "wxedge", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

local default_image = wxedge_model.default_image()
o = s:option(Value, "image_name", translate("Image").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value("onething1/wxedge", "onething1/wxedge")
o:value("onething1/wxedge:2.4.3", "onething1/wxedge:2.4.3")
o:value("registry.hub.docker.com/onething1/wxedge", "registry.hub.docker.com/onething1/wxedge")
o:value("registry.hub.docker.com/onething1/wxedge:2.4.3", "registry.hub.docker.com/onething1/wxedge:2.4.3")
o.default = default_image

local blks = wxedge_model.blocks()
local dir
o = s:option(Value, "cache_path", translate("Cache path").."<b>*</b>", "请选择合适的存储位置进行安装，安装位置容量越大，收益越高。安装后请勿轻易改动")
o.rmempty = false
o.datatype = "string"
for _, dir in pairs(blks) do
	dir = dir .. "/wxedge1"
	o:value(dir, dir)
end
if #blks > 0 then
    o.default = blks[1] .. "/wxedge1"
end

return m
