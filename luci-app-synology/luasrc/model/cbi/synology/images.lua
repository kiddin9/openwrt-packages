require "luci.sys"
local m, s, o
m = Map("synology", translate("镜像设置"))


local image_url = luci.dispatcher.build_url("admin", "services", "synology", "images", "%s")
-- [[ Servers Manage ]]--
s = m:section(TypedSection, "images")
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"
--s.extedit = luci.dispatcher.build_url("admin", "services", "synology", "images", "%s")--



o = s:option(DummyValue, "path", translate("保存路径"))
function o.cfgvalue(self, section)
	return m:get(section, "path") or Value.cfgvalue(self, section) or translate("None")
end

o = s:option(DummyValue, "size", translate("镜像大小【G】"))
function o.cfgvalue(self, section)
	return m:get(section, "size") or Value.cfgvalue(self, section) or translate("None")
end



function s.create(...)
	local sid = TypedSection.create(...)
	if sid then
		luci.http.redirect(image_url % sid)
		return
	end
end
function s.remove(self, sid)
  -- do stuff
  path = m.uci:get("synology", sid, "path")
  luci.sys.call("rm -f %s" %{path})
  return TypedSection.remove(self, sid)
end



return m