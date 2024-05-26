require "luci.sys"
require "luci.http"
local m, s, o
local sid = arg[1]
m = Map("synology", translate("编译镜像"))
m.redirect = luci.dispatcher.build_url("admin/services/synology/images")
if m.uci:get("synology", sid) ~= "images" then
	luci.http.redirect(m.redirect)
	return
end
-- [[ Servers Setting ]]--
s = m:section(NamedSection, sid, "images")
s.anonymous = true
s.addremove = false


o = s:option(Value, "path", translate("保存路径:"))
o.default = ""
o.rmempty = false
o.description = translate("镜像保存路径，后缀:qcow2")


o = s:option(Value, "size", translate("镜像大小【单位G】:"))
o.datatype = "uinteger"
o.default = "2"
o.rmempty = false


o = s:option(Button, "create", translate("创建镜像"))
o.inputstyle = "apply"
o.description = translate("创建镜像")
o.write = function(self,section)
	path = m:get(section, "path")
	size = m:get(section, "size")
	luci.sys.call("qemu-img create -f qcow2 %s %sG>/dev/null" %{path,size})
	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "synology", "images"))
end



return m