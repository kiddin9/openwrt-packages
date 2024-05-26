-- Copyright 2008 Yanira <forum-2008@email.de>
-- Licensed to the public under the Apache License 2.0.

require("nixio.fs")

m = Map("syncthing", translate("Syncthing Synchronization Tool"))

m:section(SimpleSection).template  = "syncthing/syncthing_status"

s = m:section(TypedSection, "syncthing")
s.addremove = false
s.anonymous = true

o = s:option(Flag, "enabled", translate("Enabled"))
o.default = 0
o.rmempty = false

gui_address = s:option(Value, "gui_address", translate("GUI access address"))
gui_address.description = translate("Use 0.0.0.0:8384 to monitor all access.")
gui_address.default = "http://0.0.0.0:8384"
gui_address.placeholder = "http://0.0.0.0:8384"
gui_address.rmempty = false

home = s:option(Value, "home", translate("Configuration file directory"))
home.description = translate("Only the configuration saved in /etc/syncthing will be automatically backed up!")
home.default = "/etc/syncthing"
home.placeholder = "/etc/syncthing"
home.rmempty = false

user = s:option(ListValue, "user", translate("User"))
user.description = translate("The default is syncthing, but it may cause permission denied. Syncthing officially does not recommend running as root.")
user:value("", translate("syncthing"))
for u in luci.util.execi("cat /etc/passwd | cut -d ':' -f1") do
	user:value(u)
end

macprocs = s:option(Value, "macprocs", translate("Thread limit"))
macprocs.description = translate("0 to match the number of CPUs (default), >0 to explicitly specify concurrency.")
macprocs.default = "0"
macprocs.placeholder = "0"
macprocs.datatype="range(0,32)"
macprocs.rmempty = false

nice = s:option(Value, "nice", "Nice")
nice.description = translate("Explicitly specify nice. 0 is the highest and 19 is the lowest. (negative values are not allowed to be set temporarily)")
nice.default = "19"
nice.placeholder = "19"
nice.datatype="range(0,19)"
nice.rmempty = false


return m
