#!/usr/bin/lua
-- Copyright 2019 BD7MQB (bd7mqb@qq.com)
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2
-- a DmdIds service via ubus

require "ubus" -- opkg install libubus-lua
require "uloop" -- opkg install libubox-lua

local conn = ubus.connect()
if not conn then
    error("Failed to connect to ubus")
end

local function shell(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
local function ini_load(fileName)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.')
	local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName)
	local data = {}
	local section
	for line in file:lines() do
		local tempSection = line:match('^%[([^%[%]]+)%]$')
		if(tempSection)then
			section = tonumber(tempSection) and tonumber(tempSection) or tempSection
			data[section] = data[section] or {}
		end
		local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$')
		if(param and value ~= nil)then
			if(tonumber(value))then
				value = tonumber(value)
			elseif(value == 'true')then
				value = true
			elseif(value == 'false')then
				value = false
			end
			if(tonumber(param))then
				param = tonumber(param)
			end
			data[section][param] = value
		end
	end
	file:close()
	return data
end

local function split(str, pat, max, regex)
	pat = pat or "\n"
	max = max or #str

	local t = {}
	local c = 1

	if #str == 0 then
		return {""}
	end

	if #pat == 0 then
		return nil
	end

	if max == 0 then
		return str
	end

	repeat
		local s, e = str:find(pat, c, not regex)
		max = max - 1
		if s and max < 0 then
			t[#t+1] = str:sub(c)
		else
			t[#t+1] = str:sub(c, s and s - 1)
		end
		c = e and e + 1 or #str + 1
	until not s or max < 0

	return t
end

local pid = tonumber(shell("cat /proc/self/stat | awk '{print $1}'")) or 0
local function log(msg)
    msg = string.format("dmrid[%d]: %s", pid, msg)
    print(msg)
    conn:call("log", "write", {event = msg})
end

-- local dmrid_file = ini_load("/etc/MMDVM.ini")["DMR Id Lookup"].File or "/etc/mmdvm/"
local dmrid_file = "/etc/mmdvm/"
log("Loading DMRIds from " .. dmrid_file .. " ...")
-- local user_count = load_users(dmrid_file)
-- log("Loaded " .. user_count .." Ids to the callsign lookup table ... Done")

uloop.init()

local mmdvm = require("mmdvm")
mmdvm.init(dmrid_file)

local function get_dmrid_by_callsign(req, msg)
    local result = {}

    if msg.callsign then
        -- line = mmdvm.get_dmrid_by_callsign(msg.callsign)
        -- if line then
        --     local tokens = split(line, "\t")
        --     local name = tokens[1]
        --     local city = tokens[2]
        --     local country = tokens[3]

        --     result = {
        --         callsign = msg.callsign,
        --         name = name,
        --         city = city,
        --         country = country
        --     }
        -- else
        --     result = {}
		-- end
		result = mmdvm.get_user_by_callsign(msg.callsign) or {}
        result.callsign = msg.callsign
    end

    conn:reply(req, result)
end

local dmr_api = {
    dmrid = {
        get_by_callsign = { get_dmrid_by_callsign, {} },
    }
}

conn:add(dmr_api)

-- local my_event = {
--     test = function(msg)
--         print("Call to test event")
--         for k, v in pairs(msg) do
--             print("key=" .. k .. " value=" .. tostring(v))
--         end
--     end,
-- }

-- conn:listen(my_event)

uloop.run()