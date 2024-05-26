m = Map("natter2", translate("Natter v2"),
translate("Expose your port behind full-cone NAT to the Internet")
.. [[<br /><br /><a href="https://github.com/MikeWang000000/Natter">]]
.. translate("Project")
.. [[</a>]]
)

s = m:section(TypedSection, "base")
s.addremove = false
s.anonymous = true

local function check_file(e)
	return luci.sys.exec('ls "%s" 2> /dev/null' % e) ~= "" and true or false
end

enable = s:option(Flag, "enable", translate("Enable"))
enable.default = 0

if check_file("/tmp/natter2_nat_type") then
	natter_nat_type_tcp = luci.sys.exec ("grep TCP /tmp/natter2_nat_type")
	natter_nat_type_udp = luci.sys.exec ("grep UDP /tmp/natter2_nat_type")
	nat_check = s:option (Button, "nat_check", translate("Check NAT Status"), translate("") .. "<br><br>" .. natter_nat_type_tcp .. "<br><br>" .. natter_nat_type_udp)
else
	nat_check = s:option (Button, "nat_check", translate("Check NAT Status"), translate("Tips")
	.. [[<br />]] .. translate("After clicking Exec button, please wait for the luci to refresh"))
end

nat_check.inputtitle = translate("Exec")
nat_check.write = function()
	luci.sys.call ("sh /usr/share/luci-app-natter2/nat-check.sh")
	luci.http.redirect(luci.dispatcher.build_url("admin", "network", "natter2", "base"))
end

tmp_path = s:option(Value, "tmp_path", translate("Tmp Path"))
tmp_path.default = "/tmp/natter2"
tmp_path.placeholder = "/tmp/natter2"
tmp_path.rmempty = false

s = m:section(TypedSection, "instances", translate("Instances"), translate("Setting up multiple instances"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"
s.extedit = luci.dispatcher.build_url("admin", "network", "natter2", "instances", "%s")
function s.create(...)
	local e=TypedSection.create(...)
	if e then
		luci.http.redirect(s.extedit%e)
		return
	end
end

enable_instance = s:option(Flag, "enable_instance", translate("Enable"))
enable_instance.default = 1
enable_instance.width = "5%"

remark = s:option(DummyValue,"remark",translate("Remark"))
remark.width = "5%"

protocol = s:option(DummyValue,"protocol",translate("Protocol"))
remark.width = "5%"

tmp_public_port = s:option(DummyValue, "tmp_public_port", translate("Public Port"))
remark.width = "5%"

target_address = s:option(DummyValue, "target_address", translate("Target Address"))
remark.width = "5%"

target_port = s:option(DummyValue, "target_port", translate("Target Port"))
remark.width = "5%"

notify_path = s:option(DummyValue, "notify_path", translate("Notify Script Path"))
remark.width = "5%"

return m
