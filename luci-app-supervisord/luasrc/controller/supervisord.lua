module("luci.controller.supervisord", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/supervisord") then return end
    entry({"admin", "services", "supervisord"}, cbi("supervisord"), _("Supervisord"), 95).dependent = true
    entry({"admin", "services", "supervisord", "status"}, call("status")).leaf = true
    entry({"admin", "services", "supervisord", "getver"}, call("getver")).leaf = true
    entry({"admin", "services", "supervisord", "update"}, call("update")).leaf = true
    entry({"admin", "services", "supervisord", "gettask"}, call("gettask")).leaf = true
    entry({"admin", "services", "supervisord", "starttask"}, call("starttask")).leaf = true
    entry({"admin", "services", "supervisord", "restarttask"}, call("restarttask")).leaf = true
    entry({"admin", "services", "supervisord", "stoptask"}, call("stoptask")).leaf = true
    entry({"admin", "services", "supervisord", "removetask"}, call("removetask")).leaf = true
    entry({"admin", "services", "supervisord", "addtask"}, call("addtask")).leaf = true
    entry({"admin", "services", "supervisord", "savetask"}, call("savetask")).leaf = true
    entry({"admin", "services", "supervisord", "getlog"}, call("getlog")).leaf = true
end

function Split(str, delim, maxNb)  
    -- Eliminate bad cases...  
    if string.find(str, delim) == nil then 
        return { str } 
    end 
    if maxNb == nil or maxNb < 1 then 
        maxNb = 0    -- No limit  
    end 
    local result = {} 
    local pat = "(.-)" .. delim .. "()"  
    local nb = 0 
    local lastPos  
    for part, pos in string.gfind(str, pat) do 
        nb = nb + 1 
        result[nb] = part  
        lastPos = pos  
        if nb == maxNb then break end 
    end 
    -- Handle the last field  
    if nb ~= maxNb then 
        result[nb + 1] = string.sub(str, lastPos)  
    end 
    return result  
end 

function status()
	local e = {}
	e.running = luci.sys.call("ps | grep supervisord | grep -v grep >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function getver()
	local e = {}
	local c=luci.model.uci.cursor()
    local d=c:get("supervisord", "main", "filepath")
    e.nowver=luci.sys.exec(d .. " version")
    e.newver=luci.sys.exec("uclient-fetch -qO- 'https://api.github.com/repos/ochinchina/supervisord/releases/latest' | jsonfilter -e '@.tag_name'")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function update()
	local e = {}
	local c=luci.model.uci.cursor()
    local d=c:get("supervisord", "main", "filepath")
    local version = luci.http.formvalue('version')
    local arch = nixio.uname().machine or ""
	version = version:gsub("\n", "")
    if nixio.fs.access("/usr/lib/os-release") then
        LEDE_BOARD = luci.sys.exec("echo -n $(grep 'LEDE_BOARD' /usr/lib/os-release | awk -F '[\\042\\047]' '{print $2}')")
    end
    if nixio.fs.access("/etc/openwrt_release") then
        DISTRIB_TARGET = luci.sys.exec("echo -n $(grep 'DISTRIB_TARGET' /etc/openwrt_release | awk -F '[\\042\\047]' '{print $2}')")
    end
    arch=luci.util.trim(arch)
    if arch == "x86_64" then
        arch = "64-bit"
    end
    filename = "supervisord_" .. version:gsub("v", "") .. "_Linux_" .. arch .. ".tar.gz"
    nixio.fs.remove("/tmp/" .. filename)
    u=c:get("supervisord", "main", "usechinamirror")
    if u then
		u="https://ghproxy.com/"
	else
		u=""
    end
    e.error=luci.sys.call("uclient-fetch -qO- -O '/tmp/" .. filename .. "' '" .. u .. "https://github.com/ochinchina/supervisord/releases/download/" .. version .. "/" .. filename .. "'")
    if e.error == 0 then
        e.error=luci.sys.exec("tar -xzvf '/tmp/" .. filename .. "' -C /tmp")
        if e.error then
            e.error=nixio.fs.mover("/tmp/" .. filename:gsub(".tar.gz", "") .. "/supervisord", d)
            if e.error then
                e.error=0
				sysupgrade=nixio.fs.readfile("/etc/sysupgrade.conf")
				if not sysupgrade:find(d) then
					sysupgrade=sysupgrade .. '\n' .. d
					nixio.fs.writefile ("/etc/sysupgrade.conf", sysupgrade)
				end
                luci.http.prepare_content("application/json")
    	        luci.http.write_json(e)
            end
        else
            luci.http.prepare_content("application/json")
	        luci.http.write_json(e)
        end
    else
        luci.http.prepare_content("application/json")
	    luci.http.write_json(e)
    end
end

function gettask()
	local e = {}
	local name = luci.http.formvalue('name')
	local data = luci.sys.exec("supervisord ctl status " .. name)
	e.status=string.gsub(string.sub(data, 34, 50), " ", "")
	e.description=string.sub(data, 51)
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function starttask()
	local e = {}
	local name = luci.http.formvalue('name')
	local data = luci.sys.exec("supervisord ctl start " .. name)
    if string.find(data,"started") ~= nil then
        e.code=1
    else
        e.code=0
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function restarttask()
	local e = {}
	local name = luci.http.formvalue('name')
	local data = luci.sys.exec("supervisord ctl stop " .. name .. " && supervisord ctl start " .. name)
    if string.find(data,"started") ~= nil then
        e.code=1
    else
        e.code=0
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function stoptask()
	local e = {}
	local name = luci.http.formvalue('name')
	local data = luci.sys.exec("supervisord ctl stop " .. name)
    if string.find(data,"stopped") ~= nil then
        e.code=1
    else
        e.code=0
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function removetask()
	local e = {}
	local name = luci.http.formvalue('name')
	e.code=nixio.fs.remove('/etc/supervisord/program/' .. name .. '.ini')
    if e.code then
        luci.sys.call("supervisord ctl reload")
        e.code=1
    else
        e.code=0
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function addtask()
	local e = {}
	local name = luci.http.formvalue('name')
	if nixio.fs.access('/etc/supervisord/program/' .. name .. '.ini') then
    	e.code=2
    	luci.http.prepare_content("application/json")
    	luci.http.write_json(e)
    	return
	end
	file=nixio.fs.readfile("/etc/supervisord/program/templates")
	file=file:gsub("demo", name)
	e.code=nixio.fs.writefile('/etc/supervisord/program/' .. name .. '.ini', file)
    if e.code then
        luci.sys.call("supervisord ctl reload")
        e.code=1
        e.data=file
    else
        e.code=0
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function savetask()
	local e = {}
	local name = luci.http.formvalue('name')
	local data = luci.http.formvalue('data')
	data = data:gsub("\r\n?", "\n")
	file = '/etc/supervisord/program/' .. name .. '.ini'
	e.code=nixio.fs.writefile (file, data)
    if e.code then
        sysupgrade=nixio.fs.readfile("/etc/sysupgrade.conf")
        if not sysupgrade:find(file) then
            sysupgrade=sysupgrade .. '\n' .. file
        end
        backupfile=data:match("backupfile=([%a%d%p]+)")
        backupfile=Split(backupfile, "||")
        for k, v in ipairs(backupfile) do      
            if not sysupgrade:find(v:gsub("%p", "%%%1")) then
                sysupgrade=sysupgrade .. '\n' .. v
            end
        end
        nixio.fs.writefile ("/etc/sysupgrade.conf", sysupgrade)
        luci.sys.call("supervisord ctl reload")
        e.code=1
    else
        e.code=0
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function getlog()
	local e = {}
	local name = luci.http.formvalue('name')
	if name=="main" then
    	local data = nixio.fs.readfile ('/etc/supervisord/supervisord.conf')
    	data = string.match(data, "logfile=([%a%d%p]+)")
    	e.data=nixio.fs.readfile (data)
	else
    	local data = nixio.fs.readfile ('/etc/supervisord/program/' .. name .. '.ini')
    	data = string.match(data, "stdout_logfile=([%a%d%p]+)")
    	e.data=nixio.fs.readfile (data)
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end