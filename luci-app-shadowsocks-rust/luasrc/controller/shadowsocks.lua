-- Copyright (C) 2014-2017 Jian Chang <aa65535@live.com>
-- Copyright (C) 2020-2023 honwen <https://github.com/honwen>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.shadowsocks", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/shadowsocks") then
		return
	end

	page = entry({"admin", "services", "shadowsocks"},
		alias("admin", "services", "shadowsocks", "general"),
		_("ShadowSocks"), 10)
	page.dependent = true
	page.acl_depends = { "luci-app-shadowsocks" }

	page = entry({"admin", "services", "shadowsocks", "general"},
		cbi("shadowsocks/general"),
		_("General Settings"), 10)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	page = entry({"admin", "services", "shadowsocks", "status"},
		call("action_status"))
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	page = entry({"admin", "services", "shadowsocks", "servers"},
		arcombine(cbi("shadowsocks/servers"), cbi("shadowsocks/servers-details")),
		_("Servers Manage"), 20)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	if luci.sys.call("command -v sslocal >/dev/null") ~= 0 then
		return
	end

	page = entry({"admin", "services", "shadowsocks", "access-control"},
		cbi("shadowsocks/access-control"),
		_("Access Control"), 30)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	entry({"admin", "services", "shadowsocks", "log"},
		call("action_log"),
		_("System Log"), 90)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	if luci.sys.call("command -v /etc/init.d/dnsmasq-extra >/dev/null") ~= 0 then
		return
	end

	page = entry({"admin", "services", "shadowsocks", "gfwlist"},
		call("action_gfw"),
		_("GFW-List"), 60)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

	page = entry({"admin", "services", "shadowsocks", "custom"},
		cbi("shadowsocks/gfwlist-custom"),
		_("Custom-List"), 50)
	page.leaf = true
	page.acl_depends = { "luci-app-shadowsocks" }

end

local function is_running(name)
	return luci.sys.call("pgrep -f '%s' >/dev/null" %{name}) == 0
end

function action_status()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		ss_redir = is_running("/var/run/ss-redir"),
		ss_http = is_running("/var/run/ss-local-http"),
		ss_socks = is_running("/var/run/ss-local-socks"),
		ss_tunnel = is_running("/var/run/ss-tunnel")
	})
end

function action_log()
	local conffile = "/var/log/shadowsocks_healthcheck.log"
	local healthcheck = nixio.fs.readfile(conffile) or ""
	luci.template.render("shadowsocks/plain", {content=healthcheck})
end

function action_gfw()
	local conffile = "/etc/dnsmasq-extra.d/gfwlist"
	local gfwlist = nixio.fs.readfile(conffile) or luci.sys.exec("cat %s.gz | gunzip -c" %{conffile}) or ""
	luci.template.render("shadowsocks/plain", {content=gfwlist})
end
