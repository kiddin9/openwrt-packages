
module("luci.controller.poweroffdevice", package.seeall)


function index() 
    local e = entry({"admin","system","poweroffdevice"},template("poweroffdevice/poweroffdevice"), _("PowerOff"), 92)
    e.dependent=false
    e.acl_depends = { "luci-app-poweroffdevice" }
	entry({"admin","system","poweroffdevice","call"},post("action_poweroff"))
end

function action_poweroff()
      luci.sys.exec("/sbin/poweroff" )

end
