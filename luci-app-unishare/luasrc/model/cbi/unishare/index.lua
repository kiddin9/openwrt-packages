
m = Map("unishare", nil, translate("Configure multiple file sharing protocols in one page (Samba, WebDAV, maybe more in the future?)"))

s = m:section(TypedSection, "global", translate("Global"))
s:tab("general", translate("General Setup"))
s:tab("webdav", translate("WebDAV"))
s.anonymous = true
s.addremove = false

o = s:taboption("general", Flag, "enabled", translate("Enabled"))
o.default = 0

o = s:taboption("general", Flag, "anonymous", translate("Allow Anonymous"),
    translatef("For logged in users, please manage on the '%s' page",
        "<a href=\""..luci.dispatcher.build_url("admin", "nas", "unishare", "users").."\" >"..translate("Users").."</a>"))
o.default = 0

o = s:taboption("webdav", Value, "webdav_port", translate("WebDAV Port"))
o.datatype = "port"

s = m:section(TypedSection, "share", translate("Shares"), translate("(The user marked in <b>Bold</b> has write access)"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"
s.extedit = luci.dispatcher.build_url("admin", "nas", "unishare", "share", "%s")
function s.create(...)
	local sid = TypedSection.create(...)
	luci.http.redirect(s.extedit % sid)
end

path = s:option(Value, "path", translate("Path"))
path.datatype = "string"
path.rmempty = false
path.validate = function(self, value, section)
    if value then
        if value == "/" or string.match(value, "^/.+[^/]$") then
            if value == "/" and (nil == name:formvalue(section) or "" == name:formvalue(section)) then
                return nil, translate("Name cannot be empty when Path is /")
            end
            return value
        else
            return nil, translate("Path must starts with '/' and not ends with '/'")
        end
    end
    return AbstractValue.validate(self, value, section)
end

name = s:option(Value, "name", translate("Name"))
name.datatype = "string"
name.rmempty = true
name.validate = function(self, value, section)
    if value and string.match(value, "[`&|;<>/\\*?$#]") then
        return nil, translatef("Name must not contains '%s'", "`&|;<>/\\*?$#")
    end
    return AbstractValue.validate(self, value, section)
end

local function uci2string(v, s)
    if v == nil then
        return "&#8212;"
    end
    if type(v) == "table" then
        return table.concat(v, s)
    else
        return v
    end
end

o = s:option(DummyValue, "users", translate("Users"))
o.rawhtml = true
function o.cfgvalue(self, s)
	return "<b>" .. uci2string(self.map:get(s, "rw"), " ") .. "</b><br><i>" .. uci2string(self.map:get(s, "ro"), " ") .. "</i>"
end

o = s:option(StaticList, "proto", translate("Protocol"))
o:value("samba", "Samba")
o:value("webdav", "WebDAV")

return m
