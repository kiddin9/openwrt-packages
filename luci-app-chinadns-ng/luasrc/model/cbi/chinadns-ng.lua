local m, s, o

if luci.sys.call("pidof chinadns-ng >/dev/null") == 0 then
	m = Map("chinadns-ng", translate("ChinaDNS-NG"), "%s - %s" %{translate("ChinaDNS-NG"), translate("RUNNING")})
else
	m = Map("chinadns-ng", translate("ChinaDNS-NG"), "%s - %s" %{translate("ChinaDNS-NG"), translate("NOT RUNNING")})
end

s = m:section(TypedSection, "chinadns-ng", translate("General Setting"))
s.anonymous   = true

o = s:option(Flag, "enable", translate("Enable"))
o.rmempty     = false

o = s:option(Flag, "fair_mode",
	translate("Enable the Fair_Mode"),
	translate("Enable the Fair_Mode or use the Compete_Mode. Only fair mode from version 2023.03.06"))
o.rmempty     = false

o = s:option(Value, "bind_port", translate("Listen Port"))
o.placeholder = 5353
o.default     = 5353
o.datatype    = "port"
o.rmempty     = false

o = s:option(Value, "bind_addr", translate("Listen Address"))
o.placeholder = "0.0.0.0"
o.default     = "0.0.0.0"
o.datatype    = "ipaddr"
o.rmempty     = false

o = s:option(Value, "chnlist_file", translate("CHNRoute File"))
o.placeholder = "/etc/chinadns-ng/chinalist.txt"
o.default     = "/etc/chinadns-ng/chinalist.txt"
o.rmempty     = false

o = s:option(Value, "gfwlist_file", translate("GFWRoute File"))
o.placeholder = "/etc/chinadns-ng/gfwlist.txt"
o.default     = "/etc/chinadns-ng/gfwlist.txt"
o.rmempty     = false

o = s:option(Value, "timeout_sec", translate("timeout_sec"))
o.placeholder = "3"
o.default     = "3"
o.datatype    = "uinteger"
o.rmempty     = false

o = s:option(Value, "repeat_times", translate("repeat_times"))
o.placeholder = "1"
o.default     = "1"
o.datatype    = "uinteger"
o.rmempty     = false

o = s:option(Value, "china_dns",
	translate("China DNS Servers"),
	translate("Use commas to separate multiple ip address, Max 2 Servers"))
o.placeholder = "114.114.114.114"
o.default     = "114.114.114.114"
o.rmempty     = false

o = s:option(Value, "trust_dns",
	translate("Trusted DNS Servers"),
	translate("Use commas to separate multiple ip address, Max 2 Servers"))
o.placeholder = "127.0.0.1#5300"
o.default     = "127.0.0.1#5300"
o.rmempty     = false

o = s:option(Flag, "chnlist_first",
	translate("match chnlist first"),
	translate("match chnlist first, default is gfwfirst"))
o.rmempty     = false

o = s:option(Flag, "reuse_port",
	translate("reuse_port"),
	translate("reuse_port, for Multi-process load balancing"))
o.rmempty     = false

o = s:option(Flag, "noip_as_chnip",
	translate("accept no ip"),
	translate("accept reply without ipaddr (A/AAAA query)"))
o.rmempty     = false

o = s:option(Value, "no_ipv6",
	translate("disable ipv6-address query"),
	translate("disable ipv6-address query (qtype: AAAA)"))
o:value("0", translate("none"))
o:value("a", translate("all (a)"))
o:value("m", translate("name with tag chn (m)"))
o:value("g", translate("name with tag gfw (g)"))
o:value("n", translate("name with tag none (n)"))
o:value("c", translate("do not forward to china upstream (c)"))
o:value("t", translate("do not forward to trust upstream (t)"))
o:value("C", translate("check answer ip of china upstream (C)"))
o:value("T", translate("check answer ip of trust upstream (T)"))
o.default     = "0"
o.rmempty     = false

o = s:option(Value, "default_tag", translate("Domain default tag"))
o:value("none", "none")
o:value("chn", "chn")
o:value("gfw", "gfw")
o.default     = "none"
o.rmempty     = false

o = s:option(Value, "ipset_name4", translate("Specify ipset/nftset name for china ipv4"))
o.placeholder = "chnroute"
o.default     = "chnroute"
o.rmempty     = false

o = s:option(Value, "ipset_name6", translate("Specify ipset/nftset name for china ipv6"))
o.placeholder = "chnroute6"
o.default     = "chnroute6"
o.rmempty     = false

o = s:option(Value, "add_tagchn_ip", translate("Add the ip of tag chn to ipset/nftset"),
translate("Use commas to separate ipv4 and ipv6 table name, all table name must be specified"))
o.placeholder = ""
o.default     = ""

o = s:option(Value, "add_taggfw_ip", translate("Add the ip of tag gfw to ipset/nftset"),
    translate("Use commas to separate ipv4 and ipv6 table name, all table name must be specified"))
o.placeholder = ""
o.default     = ""

o = s:option(Flag, "verbose",
	translate("Verbose log"),
	translate("Print the verbose log"))
o.rmempty     = false

return m
