m = Map("cloudreve", translate("Cloudreve"), translate("Self-hosted file management and sharing system, supports multiple storage providers.").."<br/>"..translate("Default login username: admin@cloudreve.org, password: password."))

m:section(SimpleSection).template="cloudreve/cloudreve_status"

s = m:section(TypedSection, "cloudreve")
s.anonymous=true

enabled = s:option(Flag, "enabled", translate("Enable"))
enabled.rmempty = false

port = s:option(Value,"port",translate("Port"))
port.default = "8052"
port.placeholder = "8052"
port.rmempty = false

return m
