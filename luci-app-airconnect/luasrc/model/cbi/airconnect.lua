local i = require 'luci.sys'
local m, e

m = Map('airconnect', translate('AirConnect'))
m.description = translate('Send audio to UPnP/Sonos/Chromecast players using AirPlay.')

m:section(SimpleSection).template = 'airconnect/airconnect_status'

e = m:section(TypedSection, 'airconnect')
e.addremove = false
e.anonymous = true

o = e:option(Flag, 'enabled', translate('Enabled'))
o.rmempty = false

o = e:option(Value, 'interface', translate('Bind interface'))
for t, e in ipairs(i.net.devices()) do
	if e ~= 'lo' and not string.match(e, '^docker.*$') and not string.match(e, '^sit.*$') and not string.match(e, '^dummy.*$') and not string.match(e, '^teql.*$') and not string.match(e, '^veth.*$')  and not string.match(e, '^ztly.*$') then
		o:value(e)
	end
end
o.rmempty = false

o = e:option(Flag, 'airupnp', translate('UPnP/Sonos'), translate('Enable UPnP/Sonos Device Support'))
o.rmempty = false

o = e:option(Flag, 'aircast', translate('Chromecast'), translate('Enable Chromecast Device Support'))
o.rmempty = false

return m
