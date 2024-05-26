local a=require"luci.sys"
local e=luci.model.uci.cursor()
local e=require"nixio.fs"
require("luci.sys")
local t,e,o

t=Map("tencentddns",translate("TencentDDNS"))

e=t:section(TypedSection,"base",translate("Base"))
e.anonymous=true

enable=e:option(Flag,"enable",translate("enable"))
enable.rmempty=false

enable=e:option(Flag,"ipv6",translate("ipv6"),translate("ipv6 mean"))
enable.rmempty=false

enable=e:option(Flag,"clean",translate("Clean Before Update"),translate("Clean Before Update mean"))
enable.rmempty=false
 
token=e:option(Value,"key_id",translate("Key ID"),translate("Key ID Mean"))
email=e:option(Value,"key_token",translate("Key Token"),translate("Key Token Mean"))
email.password = true

iface=e:option(ListValue,"interface",translate("WAN-IP Source"),translate("Select the WAN-IP Source for TencentDDNS, like wan/internet"))
iface:value("",translate("Select WAN-IP Source"))
iface:value("internet")
iface:value("wan")
iface:value("lan")

iface.rmempty=false
main=e:option(Value,"main_domain",translate("Main Domain"),translate("For example: test.github.com -> github.com"))
main.rmempty=false
sub=e:option(Value,"sub_domain",translate("Sub Domain"),translate("For example: test.github.com -> test"))
sub.rmempty=false
time=e:option(Value,"time",translate("Inspection Time"),translate("Unit: Minute, Range: 1-59"))
time.rmempty=false

e=t:section(TypedSection,"base",translate("Update Log"))
e.anonymous=true
local a="/var/log/tencentddns.log"
tvlog=e:option(TextValue,"sylogtext")
tvlog.rows=16
tvlog.readonly="readonly"
tvlog.wrap="off"

function tvlog.cfgvalue(e,e)
	sylogtext=""
	if a and nixio.fs.access(a) then
		sylogtext=luci.sys.exec("tail -n 100 %s"%a)
	end
	return sylogtext
end


tvlog.write=function(e,e,e)
end
local e=luci.http.formvalue("cbi.apply")
if e then
    local key, val
    local Enable
    local Keyid
    local Keytoken
    local Domain
    local Subdomian
    for key, val in pairs(luci.http.formvalue()) do
           if(string.find(key,"enable"))
           then
              Enable=val
           elseif(string.find(key,"key_id"))
           then
              Keyid=val
           elseif(string.find(key,"key_token"))
           then
              Keytoken=val
          elseif(string.find(key,"main_domain"))
          then
              Domain=val
          elseif(string.find(key,"sub_domain"))
          then
              Subdomian=val
          end
    end
    io.popen("/etc/tencentddnsupload 1 "..Keyid.." "..Domain.." "..Subdomian.." > /dev/null")
	io.popen("/etc/init.d/tencentddns restart")
end
return t
