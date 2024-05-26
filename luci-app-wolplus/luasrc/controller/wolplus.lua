module("luci.controller.wolplus", package.seeall)
local t, a
local x = luci.model.uci.cursor()

function index()
    if not nixio.fs.access("/etc/config/wolplus") then return end
    entry({"admin", "services", "wolplus"}, cbi("wolplus"), _("wolplus"), 95).dependent = true
	entry( {"admin", "services", "wolplus", "awake"}, post("awake") ).leaf = true
end

function awake(sections)
	lan = x:get("wolplus",sections,"maceth")
	mac = x:get("wolplus",sections,"macaddr")
    local e = {}
    cmd = "/usr/bin/etherwake -D -i " .. lan .. " -b " .. mac .. " 2>&1"
	local p = io.popen(cmd)
	local msg = ""
	if p then
		while true do
			local l = p:read("*l")
			if l then
				if #l > 100 then l = l:sub(1, 100) .. "..." end
				msg = msg .. l
			else
				break
			end
		end
		p:close()
	end
	e["data"] = msg
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
