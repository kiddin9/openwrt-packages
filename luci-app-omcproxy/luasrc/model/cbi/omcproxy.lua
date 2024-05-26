-- Copyright 2019-2020 Shun Li <riverscn@gmail.com>
-- Licensed to the public under the GNU General Public License v3.

local sys = require "luci.sys"
m = Map("omcproxy", translate("omcproxy"), translate("Embedded IGMPv3 and MLDv2 proxy"))
s = m:section(TypedSection, "proxy", translate("Proxy Instance"))
s.anonymous = true
s.addremove = true
s.addbtntitle = translate('Add instance')
o=s:option(ListValue, "scope", translate("Scope"), translate("Minimum multicast scope to proxy (only affects IPv6 multicast)"))
o.datatype = 'string'
o:value('', translate('default'))
o:value('global', translate('global'))
o:value('organization', translate('organization-local'))
o:value('site', translate('site-local'))
o:value('admin', translate('admin-local'))
o:value('realm', translate('realm'))
o.default = ''
o.rmempty = true

o = s:option(Value, 'uplink', translate('Uplink interface'), translate('Where does the multicast come from?'))
o.nocreate    = true
o.rmempty = false
o.template    = "cbi/network_netlist"

o = s:option(Value, 'downlink', translate('Downlink interface'), translate('Where does the multicast go to?'))
o.nocreate    = true
o.rmempty = false
o.template    = "cbi/network_netlist"

return m
