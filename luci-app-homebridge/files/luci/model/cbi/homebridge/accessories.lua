m = Map("homebridge", "Homebridge", "Accessories")
-- [[ Devices Manage ]] --                                   

s = m:section(TypedSection, "accessory")                   
s.anonymous = true                                       
s.addremove = true                                       
s.sorable = true                                         
s.template = "cbi/tblsection"                            
s.extedit = luci.dispatcher.build_url("admin/services/homebridge/accessories/%s")
function s.create(...)                                                       
        local sid = TypedSection.create(...)             
        if sid then                                      
                luci.http.redirect(s.extedit % sid)      
                return                                   
        end                                              
end                                                                          
                                              
o = s:option(DummyValue, "alias", translate("Alias"))
function o.cfgvalue(...)                             
        return Value.cfgvalue(...) or translate("None")
end                                                    
                                                                             
o = s:option(DummyValue, "ip", translate("IP"))
function o.cfgvalue(...)                       
        return Value.cfgvalue(...) or "?"            
end 

return m
