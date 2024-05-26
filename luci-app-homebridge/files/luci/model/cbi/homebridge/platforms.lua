local ucursor = require "luci.model.uci".cursor()
local json = require "luci.jsonc"
m=Map("homebridge", "Homebridge", "Platforms configuration")
s = m:section(TypedSection, "platform", "Platforms Configuration") 
s.anonymous = true                                       
s.addremove = true                                       
s.sorable = true                                         
s.template = "cbi/tblsection"                            
s.extedit = luci.dispatcher.build_url("admin/services/homebridge/platforms/%s")
function s.create(...)                                                       
        local sid = TypedSection.create(...)             
        if sid then                                      
                luci.http.redirect(s.extedit % sid)      
                return                                   
        end                                              
end                                                                          
o = s:option(DummyValue, "alias", translate("Alias"))
function o.cfgvalue(...)                             
        return Value.cfgvalue(...) or "?"            
end                                                    

o = s:option(DummyValue, "is_independent", "Independent")
function o.cfgvalue(...)
	local v = Value.cfgvalue(...)
	local ret
	if v=="1" then
		ret = "Independent"
	else
		ret = "Main"
	end
	return ret 
end

o = s:option(DummyValue, "username", translate("MAC Address"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "ip", translate("IP"))
function o.cfgvalue(...)                       
        return Value.cfgvalue(...) or "?"            
end 

o = s:option(DummyValue, "port", translate("Port"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "pin", "pin")
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "port", translate("Process Status"))
o.template="homebridge/process_status"
o.width="10%"

m:append(Template("homebridge/platform_list"))

local ucursor = require "luci.model.uci".cursor()
local model = ucursor:get("homebridge", "@homebridge[0]","model")

--if model == "independent" or model == "combine" then
--	o = s:option(Button, "restart", translate("Restart"))
--	o.inputstyle = "exec"
--	function o.write(self, section)
--		luci.sys.exec("export HOME='/root';/etc/init.d/homebridge restart_on " .. section .. " >> /var/log/homebridge.log")	
--	end

--	o = s:option(Button, "stop", translate("Stop"))
--	o.inputstyle = "exec"
--	function o.write(self, section)
--		luci.sys.exec("export HOME=/root; /etc/init.d/homebridge stop_sub_service " .. section .. " >> /var/log/homebridge.log")
--	end
--end 

--local apply=luci.http.formvalue("cbi.apply")
--if apply then
--	luci.sys.exec("export HOME=/root;/etc/init.d/homebridge restart")
--end

return m
