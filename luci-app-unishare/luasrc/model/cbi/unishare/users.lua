
m = Map("unishare")

s = m:section(TypedSection, "user", translate("Users"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

o = s:option(Value, "username", translate("Username"),
    translate("Note: Do not use the 'root' user, as Samba forbids 'root' user login by default"))
o.datatype = "string"
o.rmempty = false
o.validate = function(self, value)
    if value and string.match(value, "^%l[%l%d_-]*$") then
        return value
    else
        return nil, translatef("Username must matchs regex '%s'", "^[a-z][a-z0-9_-]*$")
    end
end

o = s:option(Value, "password", translate("Password"))
o.datatype = "string"
o.password = true
o.rmempty = true

return m
