local ucursor = require "luci.model.uci".cursor()
local json = require "luci.jsonc"

local path = "/usr/share/homebridge/devices/"

local configs = ucursor:get_all("homebridge")

function addToSet(set, key)
	set[key] = true
end

function removeFromSet(set, key)
	set[key] = nil
end

function setContains(set, key)
	return set[key] ~= nil
end

local config_array={}
addToSet(config_array, "main")
for key, value in pairs(configs) do
	addToSet(config_array, key)
end

--print(json.stringify(config_array, 1))

files = io.popen("ls " .. path):lines()
for file in files do
	if not setContains(config_array, file) then
		print("remove directory or file:" .. file)
		os.execute("rm -rf " .. path ..file)
	end
end


















