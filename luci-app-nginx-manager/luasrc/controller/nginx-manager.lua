module("luci.controller.nginx-manager", package.seeall)

function index()
    nixio.fs.rename ("/etc/nginx/uci.conf", "/etc/nginx/ucibak.conf")
    if not nixio.fs.access("/etc/nginx/nginx.conf") then
        nixio.fs.copyr("/var/lib/nginx/uci.conf", "/etc/nginx/nginx.conf")
        luci.sys.call("/etc/init.d/nginx restart")
    end
    file=nixio.fs.readfile("/etc/uwsgi/vassals/luci-webui.ini")
    if tonumber(file:match("limit%pas[%p%s]+(%d+)")) < 5000 then
    	file=file:gsub("limit%pas[%p%s]+(%d+)","limit-as = 5000")
    	nixio.fs.writefile("/etc/uwsgi/vassals/luci-webui.ini", file)
    	luci.sys.call("/etc/init.d/uwsgi restart")
    end
    nixio.fs.writefile("/etc/config/nginx-manager", "")
    x = luci.model.uci.cursor()
    x:set("nginx-manager", "config", "nginx")
    x:set("nginx-manager", "config", "name", "config")
    x:set("nginx-manager", "config", "filepath", "/etc/config/nginx")
    for path in nixio.fs.dir("/etc/nginx/conf.d") do
        if path:find(".conf$") ~= nil then
            name = path:gsub(".conf", "")
            x:set("nginx-manager", name, "nginx")
            x:set("nginx-manager", name, "name", name)
            x:set("nginx-manager", name, "filepath", "/etc/nginx/conf.d/" .. path)
    	end
    end
    x:commit("nginx-manager")
    entry({"admin", "services", "nginx-manager"}, cbi("nginx-manager"), _("Nginx Manager"), 95).dependent = true
    entry({"admin", "services", "nginx-manager", "setstatus"}, call("setstatus")).leaf = true
end

function setstatus()
	local e = {}
	local mode = luci.http.formvalue('mode')
	e.code=luci.sys.call("/etc/init.d/nginx " .. mode)
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end