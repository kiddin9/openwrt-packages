-- Copyright 2021-2022 Lienol <lawlienol@gmail.com>
module("luci.controller.openvpn-client", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/luci-app-openvpn-client") then return end

    entry({"admin", "vpn"}, firstchild(), "VPN", 45).dependent = false
    entry({"admin", "vpn", "openvpn-client"}, cbi("openvpn-client/settings"), _("OpenVPN Client"), 50).acl_depends = { "luci-app-openvpn-client" }
    entry({"admin", "vpn", "openvpn-client", "client"}, cbi("openvpn-client/client")).leaf = true
end
