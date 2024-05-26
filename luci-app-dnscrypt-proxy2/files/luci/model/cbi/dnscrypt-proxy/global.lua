-- Copyright (C) 2019 github.com/peter-tank
-- Licensed to the public under the GNU General Public License v3.

local m, _, s, o, id, cfg, src, val, k, v
local cfg="dnscrypt-proxy"

local sys = require "luci.sys"
local http = require "luci.http"
local disp = require "luci.dispatcher"
local fs = require "nixio.fs"
local dc = require "luci.tools.dnscrypt".init()
local resolvers = dc:resolvers_list(true)

local caches_list = {}
local caches="/usr/share/dnscrypt-proxy/*"
for name in (fs.glob(caches) or function() end) do
  caches_list[#caches_list+1] = name
end

local function has_bin(name)
	return sys.call("command -v %s >/dev/null" %{name}) == 0
end
local has_dnscrypt = has_bin("dnscrypt-proxy")

local bin_version
local bin_file="/usr/sbin/dnscrypt-proxy"
if not fs.access(bin_file)  then
 bin_version=translate("Not exist")
else
 if not fs.access(bin_file, "rwx", "rx", "rx") then
   fs.chmod(bin_file, 755)
 end
 bin_version=luci.util.trim(luci.sys.exec(bin_file .. " -version"))
 if not bin_version or bin_version == "" then
     bin_version = translate("Unknown")
 end
end

m = Map(cfg, "%s - %s" %{translate("DNSCrypt Proxy"),
		translate("Overview")})
m.pageaction = false

-- [[ Binary ]]--
s = m:section(TypedSection, cfg, translate("Binary Management"), has_dnscrypt and "" or ('<b style="color:red">%s</b>' % translate("DNSCrypt Proxy binary not found.")))
s.anonymous = true
o = s:option(DummyValue,"dnscrypt_bin", translate("Binary update"))
o.rawhtml  = true
o.template = "dnscrypt-proxy/refresh"
o.name = translate("Update")
o.ret = bin_version:match('^1%..*') and  translate("Version2 atleast: ") or translate("Current version: ")
o.value = o.ret .. bin_version
o.description = translate("Update to final release from: ") .. "https://github.com/dnscrypt/dnscrypt-proxy/releases"
o.write = function (self, ...) end

o = s:option(Button, "Force Reload", translate("Force Reload"), translate("Proxy force reload, ") .. "/etc/init.d/dnscrypt-proxy reload")
o.inputstyle = "reset"
o.write = function (self, ...)
  sys.call("/etc/init.d/dnscrypt-proxy reload >/dev/null 2>&1 &")
  http.redirect(disp.build_url("admin", "services", "dnscrypt-proxy"))
end

o = s:option(Button, "dnscrypt_ck", translate("DNS resolve test"))
o.rawhtml  = true
o.template = "dnscrypt-proxy/resolve"
o.description = translate("Check DNSCrypt resolver: ") .. "/usr/sbin/dnscrypt-proxy -resolve www.google.com,127.0.0.1:7915 -config /var/etc/dnscrypt-proxy-ns1.conf"

-- [[ Caches ]]--
s = m:section(TypedSection, cfg, translate("Cache Management"), translate("Running resolver details and offline caches manipulating."))
s.anonymous = true
o = s:option(Button,"dump_resolver", translate("Dump Details"))
o.rawhtml  = true
o.template = "dnscrypt-proxy/refresh"
o.ret = translate("JSON dumped ")
o.value = " %d %s" % {#resolvers, translate("Records")}
o.description = translate("Dump DNSCrypt resolver details to cache file: ") .. "dnscrypt-proxy -json --list-all > /usr/share/dnscrypt-proxy/running.json"

o = s:option(Button, "remove_caches", translate("Remove cache files"))
o.rawhtml  = true
o.template = "dnscrypt-proxy/refresh"
o.name = translate("Remove")
o.ret = translate("Resolver cache ")
o.value = " %d %s" % {#caches_list, translate("files")}
o.description = translate("Remove cached resolvers info from: ") .. "/usr/share/dnscrypt-proxy/*"

return m

