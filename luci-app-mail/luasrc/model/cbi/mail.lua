-- Copyright 2018 Ycarus (Yannick Chabanois) <ycarus@zugaina.org>
-- Licensed to the public under the Apache License 2.0.

m = Map("mail", translate("Mail settings"), translate("Set mail settings for services that need to send mails."))

s = m:section(TypedSection, "smtp", translate("SMTP"))
s.anonymous = true
s.addremove = false

server = s:option(Value, "server", translate("Server"))
server.datatype = "host"
server.placeholder = "smtp.gmail.com"
server.optional = false

port = s:option(Value, "port", translate("Port"))
port.datatype = "port"
port.optional = false
port.rmempty  = true
port.default = "25"

tls = s:option(Flag, "tls", translate("TLS"))
tls.rmempty  = false

tls_starttls = s:option(Flag, "tls_starttls", translate("STARTTLS"))
tls_starttls.rmempty  = false

user = s:option(Value, "user", translate("Username"))
user.rmempty = true

password = s:option(Value, "password", translate("Password"))
password.password = true
password.rmempty = true

from = s:option(Value, "from", translate("From"))
from.optional = false
from.rmempty = true
from.placeholder = "myself@gmail.com"

to = s:option(Value, "to", translate("To"))
to.optional = false
to.rmempty = true
to.placeholder = "myself@gmail.com"

return m
