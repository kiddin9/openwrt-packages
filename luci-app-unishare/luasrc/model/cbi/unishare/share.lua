
local uci = luci.model.uci.cursor()

local users = {}
uci:foreach("unishare", "user", function(e)
    users[#users+1] = e["username"]
end)

m = Map("unishare", translate("Configure Share"))
m.redirect = luci.dispatcher.build_url("admin", "nas", "unishare", "index")
function m.on_save()
    luci.http.redirect(m.redirect)
end

s = m:section(NamedSection, arg[1], "share", "")
s.addremove = false
s.dynamic = false

path = s:option(Value, "path", translate("Path"), 
    translate("Note: '/mnt' is not suitable as a writable share, because Windows will recognize the wrong capacity"))
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

o = s:option(StaticList, "rw", translate("Read/Write Users"),
    translatef("'Everyone' includes anonymous if enabled, 'Logged Users' includes all users configured in '%s' tab", 
        "<a href=\""..luci.dispatcher.build_url("admin", "nas", "unishare", "users").."\" >"..translate("Users").."</a>"))
o:value("everyone", translate("Everyone"))
o:value("users", translate("Logged Users"))
for k, u in pairs(users) do
    o:value(u)
end

o = s:option(StaticList, "ro", translate("Read Only Users"))
o:value("everyone", translate("Everyone"))
o:value("users", translate("Logged Users"))
for k, u in pairs(users) do
    o:value(u)
end

o = s:option(StaticList, "proto", translate("Protocol"))
o:value("samba", "Samba")
o:value("webdav", "WebDAV")

return m
