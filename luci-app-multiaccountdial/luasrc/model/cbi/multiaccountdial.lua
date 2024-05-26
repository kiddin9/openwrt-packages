m = Map("multiaccountdial")
local fs = require "nixio.fs"

if not fs.access("/etc/multiaccountdial/") then
    fs.mkdir("/etc/multiaccountdial/")
end

if not fs.access("/etc/multiaccountdial/config") then
    fs.writefile("/etc/multiaccountdial/config","")
end




syncdial_status = m:section(SimpleSection, "dial_status", translate("dial_status"))
syncdial_status.template = "multiaccountdial/dial_status"


base_setting_section = m:section(TypedSection, "base_setting", translate("base setting"))
base_setting_section.anonymous = false
base_setting_section.addremove = false

dial_num = base_setting_section:option(Value, "dial_num", translate("多拨数量"))
dial_num.default = 2
dial_num.datatype = "range(1,249)"

o = base_setting_section:option(DummyValue, "_redial", translate("重新并发拨号"))
o.template = "multiaccountdial/redial_button"
o.width = "10%"

add_vwan = base_setting_section:option(DummyValue, "_add_vwan", translate("添加虚拟wan口"))
add_vwan.template = "multiaccountdial/add_vwan_button"
add_vwan.width = "10%"

del_vwan = base_setting_section:option(DummyValue, "_del_vwan", translate("删除虚拟wan口"))
del_vwan.template = "multiaccountdial/del_vwan_button"
del_vwan.width = "10%"



o = base_setting_section:option(Flag, "add_mwan", translate("自动配置mwan3"))
o.rmempty = false


config = base_setting_section:option(TextValue, "config")
config.description = "写成如下形式:\npppoe账号,pppoe密码,接口名称,vlan_tag"
config.template = "cbi/tvalue"
config.title = "配置文件"
config.rows = 25
config.wrap = "off"


function config.cfgvalue(self, section)
    return fs.readfile("/etc/multiaccountdial/config")
end

function config.write(self,section,value)
    value = value:gsub("\r\n?", "\n")
    fs.writefile("/etc/multiaccountdial/config", value)
end

return m







