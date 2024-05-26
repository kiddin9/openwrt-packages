-------------------------------------------------------------
-- A module for working with the "WIALON IPS" navigation protocol.
-- This module saves navigation data in case of signal loss 
-- (if it is not possible to transfer data to the server)
-------------------------------------------------------------
-- Copyright 2021-2022 Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0

local json = require("luci.jsonc")
local checksum = require("checksum")

local wialon_ips_boof = {}

-- Extended Data package
local function transformBooferData(GnssData, params)
    local D = {"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","","NA","NA"}
    if not GnssData.warning.rmc[1] then
        D[1], D[2]  = GnssData.rmc.date, GnssData.rmc.utc
    else
    	D[1], D[2]  = os.date("%d%m%y"), os.date("%H%M%S",os.time(os.date("!*t"))) .. ".00"
    end
    if not GnssData.warning.gga[1] then
        -- Lat2[4], Lon2[6] - NA
        D[3], D[5]  = GnssData.gga.latitude, GnssData.gga.longitude
        D[9], D[10] = GnssData.gga.alt, GnssData.gga.sat
        D[11] = GnssData.gga.hdp
    elseif not GnssData.warning.gns[1] then
        D[3], D[5]  = GnssData.gns.latitude, GnssData.gns.longitude
        D[9], D[10] = GnssData.gns.alt, GnssData.gns.sat
        D[11] = GnssData.gns.hdp
    elseif not GnssData.warning.locator[1] then
        D[3], D[5]  = GnssData.gga.latitude, '0' .. GnssData.gga.longitude
    end
    if not GnssData.warning.vtg[1] then
        D[7], D[8]  = GnssData.vtg.speed, GnssData.vtg.course_t
    end
    if params then
        D[16] = string.format("%s:%s:%s", params[1], params[2], params[3])
    else
        D[16] = string.format("%s:%s:%s", "boof", '3', "Data from boofer")
    end
   	
    return table.concat(D, ";")
end

-- read GNSS data from file
local function readBoof()
    local file = io.open("/usr/share/gpoint/tmp/blackbox.json", 'r')
    if not file then return nil end
    local bb_data = json.parse(file:read("*a"))
    file:close()
    return bb_data
end

-- write GNSS data to file
local function writeBoof(boof)
    local file = io.open("/usr/share/gpoint/tmp/blackbox.json", 'w')
    file:write(json.stringify(boof))
    file:close()
end

-- create boofer with data if 
local function createBoof(size)
    local BLACKBOX = { ["size"]=0,["max"]=tonumber(size),["data"]={} }
	writeBoof(BLACKBOX)
	return BLACKBOX
end

-- Package from the black box
local function parseBlackBoxData(data)
    local B = ""
    for _, gnss_msg in pairs(data) do
    	B = B .. gnss_msg .. '|'
    end
    return "#B#" .. B .. checksum.crc16(B) .. "\r\n"
end

-- get data from the black box
function wialon_ips_boof.get(serverConfig)
	if not serverConfig.blackbox.enable then
		return -1, nil
	end
	
	local blackbox = readBoof()
	if blackbox == nil or tonumber(blackbox.max) ~= tonumber(serverConfig.blackbox.size) then
		blackbox = createBoof(serverConfig.blackbox.size)
	end

	return blackbox.size, parseBlackBoxData(blackbox.data)
end

-- send data to the black box
function wialon_ips_boof.set(GnssData, serverConfig)
	
	if not serverConfig.blackbox.enable then
		return -1
	end

    local blackbox = readBoof()
    if blackbox == nil or tonumber(blackbox.max) ~= tonumber(serverConfig.blackbox.size) then
        blackbox = createBoof(serverConfig.blackbox.size)
    end
    
    if blackbox.size < blackbox.max then
         blackbox.size = blackbox.size + 1
    elseif serverConfig.blackbox.cycle then
        blackbox.size = 1
    end

    blackbox.data[blackbox.size] = transformBooferData(GnssData)
    writeBoof(blackbox)
end

-- clear the black box
function wialon_ips_boof.clean(serverConfig)
	createBoof(serverConfig.blackbox.size)
end

return wialon_ips_boof