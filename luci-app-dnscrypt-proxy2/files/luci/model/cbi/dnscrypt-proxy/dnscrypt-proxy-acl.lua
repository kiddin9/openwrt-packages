-- Copyright (C) 2019 github.com/peter-tank
-- Licensed to the public under the GNU General Public License v3.

local disp = require "luci.dispatcher"
local m, _, s, o
local cfg="dnscrypt-proxy"

m = Map(cfg, "%s - %s" %{translate("DNSCrypt Proxy"),
		translate("ACL Setting")})

-- [[ ACL Setting ]]--
s = m:section(TypedSection, "server_addr", translate("DNSCrypt Resolver ACL"), translate("DNSCrypt will automatically pick the fastest, working servers from the list<br />All or filtered out addresses are prepared for 'Address filter list(ipset)'.<br />Resolver with detailed addresses is a must.") .. " https://dnscrypt.info/stamps/")
	s.sectionhead = translate("Alias")
	s.template = "cbi/tblsection"
	s.addremove = true
	s.anonymous = true
	s.sortable = false
	s.template_addremove = "dnscrypt-proxy/cbi_addserver"

function s.create(self, section)
	local a = m:formvalue("_newsrv.alias")
	local c = m:formvalue("_newsrv.country")
	local n = m:formvalue("_newsrv.name")
	local ad = m:formvalue("_newsrv.addrs")
	local po = m:formvalue("_newsrv.ports")
	local pr = m:formvalue("_newsrv.proto")
	local st = m:formvalue("_newsrv.stamp")

	created = nil
	if a ~= "" and n ~= "" and ad ~= "" and st ~= "" then
		created = TypedSection.create(self, section)

		self.map:set(created, "alias", a)
		self.map:set(created, "country", c or "Unknown")
		self.map:set(created, "name", n or "Custom")
		self.map:set(created, "addrs", ad)
		self.map:set(created, "ports", po or "ALL")
		self.map:set(created, "proto", pr or "Unknown")
		self.map:set(created, "stamp", st or "Error")
	end
end

function s.parse(self, ...)
	TypedSection.parse(self, ...)
	if created then
		m.uci:save("dnscrypt-proxy")
		luci.http.redirect(disp.build_url("admin", "services", "dnscrypt-proxy", "dnscrypt-proxy-acl"))
	end
end

	s:option(DummyValue,"alias",translate("Alias"))
	s:option(DummyValue,"country",translate("Country"))
	s:option(DummyValue,"proto",translate("Protocol"))
	s:option(DummyValue,"name",translate("Resolver"))
	s:option(DummyValue,"addrs",translate("Address"))
	s:option(DummyValue,"ports",translate("Server Port"))
	s:option(DummyValue,"stamp",translate("Stamp"))

return m

