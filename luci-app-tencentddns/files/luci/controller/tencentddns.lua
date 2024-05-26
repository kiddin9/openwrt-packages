module("luci.controller.tencentddns",package.seeall)
function index()
entry({"admin", "services"}, firstchild(), "Services", 30).dependent=false
entry({"admin", "services", "tencentddns"},cbi("tencentddns"),_("TencentDDNS"),2)
end
 