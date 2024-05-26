-- Copyright (C) 2019 github.com/peter-tank
-- Licensed to the public under the GNU General Public License v3.

local m, _, s, o, id, cfg, src, val, k, v
local uci = luci.model.uci.cursor()
local dc = require "luci.tools.dnscrypt".init()
local resolvers = dc:resolvers_list(true)
local disp = require "luci.dispatcher"

cfg = "dnscrypt-proxy"

local dnslist_table = {}
for _, s in pairs(dc:dns_list()) do
	if s.addrs ~= nil then
		dnslist_table[#dnslist_table+1] = "%s.%s:%s@%s://%s:%s" %{s.resolver, s.country, s.name,  s.proto, s.addrs, s.ports}
	end
end

-- [[ Servers Setting ]]--
m = Map(cfg, translate("DNSCrypt Resolvers"))
m.anonymous = true
m.addremove = false
m.pageaction = false

local type = "dnscrypt-proxy"
s = m:section(NamedSection, 'ns1', type, translate("Choose a resolver to configure"), translate("Input the name to re-configure, if your resolvers not updated correctly and not showns up."))
s.cfgvalue = function(self, section) return resolvers end
s.template = "dnscrypt-proxy/cfgselection"
s.extedit = luci.dispatcher.build_url("admin/services/dnscrypt-proxy/dnscrypt-resolvers", "%s")

--s = m:section(NamedSection, 'ns1', type, translate("DNSCrypt Resolvers update"))

o = s:option(TextValue, "_Dummy", translate("DNSCrypt Resolver Info"), translate("Total %d records.") % #dnslist_table)
o.rows = 7
o.readonly = true
o.wrap = "soft"
o.cfgvalue = function (self, sec)
local ret = translate("Available Resolvers:")
for k, v in pairs(dnslist_table) do ret = "%s\n%03d) %s" % {ret, k, v} end
return ret
end
o.write = function (...) end

o = s:option(Button,"trash", translate("Trash Resolver Info"))
o.inputstyle = "reset"
o.write = function()
local resolver
for _, val in pairs(resolvers) do
  resolver = luci.util.split(val, "|")[1]
  uci:delete_all(resolver, "dnscrypt", function(s) return true end)
  uci:save(resolver)
end
end

return m
