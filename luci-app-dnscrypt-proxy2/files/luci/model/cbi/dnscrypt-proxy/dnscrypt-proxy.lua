-- Copyright (C) 2019 github.com/peter-tank
-- Licensed to the public under the GNU General Public License v3.

local m, _, s, o
local dc = require "luci.tools.dnscrypt".init()
local resolvers = dc:resolvers_list(true)
local cfg = "dnscrypt-proxy"

m = Map(cfg, "%s - %s" %{translate("DNSCrypt Proxy"), translate("Proxy Setting")})

-- [[ Proxy Setting ]]--
local type = "dnscrypt-proxy"
s = m:section(TypedSection, type)
s.anonymous = false
-- section might not exist
function s.cfgvalue(self, section)
	if not self.map:get(section) then
 	 self.map:set(section, nil, self.sectiontype)
 	 self.map:set(section, "resolvers", {"public-resolvers", "opennic"})
	end
	return self.map:get(section)
end

o = s:option(Flag, "enable", translate("Enable"))
o.default = false
o.optional = false

o = s:option(Value, "listen_addresses", translate("Listening address"), translate("Split MultiValues by a comma"))
o.default = "127.0.0.1:5335"
o.placeholder = o.default
o.optional = false
o.rmempty = false

o = s:option(Value, "netprobe_address", translate("Net probe address"), translate("Resolver on downloading resolver lists file."))
o.default = "114.114.114.114:53"
o.placeholder = o.default
o.optional = false
o.rmempty = false

o = s:option(Value, "bootstrap_resolvers", translate("Fallback resolvers"), translate("DNS resolver on query fails or for forced forwarding domain list.") .. translate("Split MultiValues by a comma"))
o.default = "114.114.114.114:53"
o.placeholder = o.default
o.optional = false
o.rmempty = false

o = s:option(DynamicList, "resolvers", translate("Enabled Resolvers"), translate("Available Resolvers: ") .. "https://download.dnscrypt.info/dnscrypt-resolvers/v2/{*}.md")
local opt, val
for _, val in ipairs(resolvers) do
  opt = luci.util.split(val, "|")[1]
  o:value(opt, translate(opt))
end
o.optional = false
o.rmempty = false
o.placeholder = "onion-services"

o = s:option(MultiValue, "force", translate("Force Options"), translate("Items forced for checking, will show your the defaults when unchecked all."))
o.optional = false
o.widget = "select"
o.force_defaults = {
["lb_estimator"] = "true",
["ignore_system_dns"] = "true",
["block_unqualified"] = "true",
["block_undelegated"] = "true",
["ipv4_servers"] = "true",
["ipv6_servers"] = "false",
["block_ipv6"] = "true",
["dnscrypt_servers"] = "true",
["doh_servers"] = "true",
["require_dnssec"] = "false",
["force_tcp"] = "false",
["require_nolog"] = "true",
["require_nofilter"] = "true",
["cache"] = "true",
["offline_mode"] = "false",
["dnscrypt_ephemeral_keys"] = "false",
["tls_disable_session_tickets"] = "false",
["cert_ignore_timestamp"] = "true",
["use_syslog"] = "false",
}
for k, v in pairs(o.force_defaults) do o:value(k, translate(k)) end
o.cfgvalue = function (self, section)
local ret, k, d
ret = Value.cfgvalue(self, section)
if ret then return ret end
ret = ""
for k, d in pairs(self.force_defaults) do
  if d == "true" then
    ret = ret .. self.delimiter .. k
  end
end
return ret
end

o = s:option(ListValue, "log_level", translate("Log output level"))
o:value(0, translate("Debug"))
o:value(1, translate("Info"))
o:value(2, translate("Notice"))
o:value(3, translate("Warning"))
o:value(4, translate("Error"))
o:value(5, translate("Critical"))
o:value(6, translate("Fatal"))
o.default = 2
o.optional = true
o.rmempty = true

o = s:option(ListValue, "blocked_query_response", translate("Response for blocked queries."))
o:value("refused", translate("refused"))
o:value("hinfo", translate("hinfo"))
o.default = "hinfo"
o.placeholder = "eg: a:<IPv4>,aaaa:<IPv6>"
o.optional = true
o.rmempty = true

o = s:option(ListValue, "lb_strategy", translate("Load-balancing strategy"))
o:value("p2", translate("p2"))
o:value("ph", translate("ph"))
o:value("first", translate("first"))
o:value("random", translate("random"))
o.default = "p2"
o.optional = true
o.rmempty = true

o = s:option(DynamicList, "forwarding_rules", translate("Forwarding2Fallback"), translate("Domains forced to fallback resolver, [.conf] file treat like dnsmasq configure."))
o.default = "/etc/dnsmasq.oversea/oversea_list.conf"
o.placeholder = "/etc/dnsmasq.oversea/oversea_list.conf"
o.optional = true
o.rmempty = true

o = s:option(DynamicList, "blocked_named", translate("Domain Black List"), translate("Domains to blacklist, [.conf|.adblock] file treat like dnsmasq configure: ") .. "https://download.dnscrypt.info/blacklists/domains/mybase.txt")
o.default = "/etc/dnsmasq.ssr/ad.conf"
o.placeholder = "/usr/share/adbyby/dnsmasq.adblock"
o.optional = true
o.rmempty = true

o = s:option(DynamicList, "blocked_ips", translate("IP Address List"), translate("IP Address to blacklist, [.conf] file treat like dnsmasq configure: ") .. "https://download.dnscrypt.info/blacklists/ips/mybase.txt")
o.default = "https://download.dnscrypt.info/blacklists/domains/mybase.txt"
o.placeholder = "/etc/dnsmasq.ssr/ad.conf"
o.optional = true
o.rmempty = true

o = s:option(DynamicList, "static", translate("Static Stamp"), translate("Mostly useful for testing your own servers."))
o.optional = true
o.rmempty = true
o.placeholder = "eg: sdns:AQcAAAAAAAAAAAAQMi5kbnNjcnlwdC1jZXJ0Lg"

o = s:option(Value, "server_names", translate("Resolver White List"), "%s %s" % {translate("Resolver white list by name, Allow *ALL* in default."), translate("Split MultiValues by a comma")})
o.optional = true
o.rmempty = true
o.placeholder = "eg: goodguy1,goodguy2"

o = s:option(Value, "disabled_server_names", translate("Resolver Black List"), "%s %s" % {translate("Resolver black list by name, disable specified resolver."), translate("Split MultiValues by a comma")})
o.optional = true
o.rmempty = true
o.placeholder = "eg: badguy1,badguy2"

o = s:option(Value, "max_clients", translate("Simulaneous"), translate("Maximum number of simultaneous client connections to accept."))
o.optional = true
o.rmempty = true
o.datatype = "uinteger"
o.default = 500
o.placeholder = o.default

o = s:option(Value, "keepalive", translate("Keep Alive"), translate("Keepalive for HTTP (HTTPS, HTTP/2) queries, in seconds."))
o.optional = true
o.rmempty = true
o.datatype = "uinteger"
o.default = 30
o.placeholder = o.default

o = s:option(Value, "cert_refresh_delay", translate("Cert refresh delay"), translate("Delay, in minutes, after which certificates are reloaded."))
o.optional = true
o.rmempty = true
o.datatype = "uinteger"
o.default = 240
o.placeholder = o.default

o = s:option(Value, "netprobe_timeout", translate("Net probe timer"), translate("Maximum time (in seconds) to wait for network connectivity before initializing the proxy."))
o.optional = true
o.rmempty = true
o.datatype = "uinteger"
o.default = 60
o.placeholder = o.default

o = s:option(Value, "reject_ttl", translate("Reject TTL"), translate("TTL for synthetic responses sent when a request has been blocked (due to IPv6 or blacklists)."))
o.optional = true
o.rmempty = true
o.datatype = "uinteger"
o.default = 60
o.placeholder = o.default

o = s:option(Value, "cache_size", translate("Cache size"), translate("Cache size for queries."))
o.optional = true
o.rmempty = true
o.datatype = "uinteger"
o.default = 512
o.placeholder = o.default

o = s:option(Value, "query_meta", translate("Additional TXT records"), translate("Additional data to attach to outgoing queries.") .. [[<br />]] .. translate("Split MultiValues by a comma"))
o.optional = true
o.rmempty = true
o.placeholder = "eg: key1:value1,key2:value2"

o = s:option(Value, "proxy", translate("SOCKS proxy"), translate("Tor doesn't support UDP, so set `force_tcp` to `true` as well."))
o.optional = true
o.rmempty = true
o.placeholder = "eg: socks5://127.0.0.1:9050"

o = s:option(Value, "http_proxy", translate("HTTP/HTTPS proxy"), translate("Only for DoH servers."))
o.optional = true
o.rmempty = true
o.placeholder = "eg: http://127.0.0.1:8888"

o = s:option(DynamicList, "cloaking_rules", translate("Cloaking rules"), translate("Cloaking returns a predefined address for a specific name."))
o.optional = true
o.rmempty = true
o.placeholder = "eg: /usr/share/dnscrypt-proxy/cloaking-rules.txt"

o = s:option(Value, "addr_filter", translate("Address filter list(ipset)"), translate("The ipset list name that DNSCrypt server addresses try appending to if any."))
o:value("auto", translate("Follwing available one (auto)"))
o:value("vpsiplist", translate("PassWall direct (vpsiplist)"))
o:value("localnetwork", translate("Clash direct (localnetwork)"))
o:value("ss_spec_wan_ac", translate("SSR-Plus direct (ss_spec_wan_ac)"))
o.optional = false
o.rmempty = true
o.default = "auto"
o.placeholder = "e.g.: gfwlist"

return m

