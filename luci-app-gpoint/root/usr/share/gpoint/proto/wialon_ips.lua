-------------------------------------------------------------
-- A module for working with the "WIALON IPS" navigation protocol.
-- This module prepares and sends data to a remote server.
-------------------------------------------------------------
-- Copyright 2021-2023 Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0

local json = require("luci.jsonc")
local checksum = require("checksum")
local blackbox = require("wialon_ips_boof")
local socket = require("socket")
local tcp = assert(socket.tcp())

local wialon_ips = {}

-- add optional field in package
local function addOptional(field ,name, data_type, value)
    if field == "NA" then
        return string.format("%s:%s:%s", name, data_type, value)
    end
    return field .. string.format(",%s:%s:%s", name, data_type, value)
end

-- Abbreviated data package
local function shortData(GnssData)
    local SD = {"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"}
    if not GnssData.warning.rmc[1] then
        SD[1], SD[2]  = GnssData.rmc.date, GnssData.rmc.utc
    end
    if not GnssData.warning.gga[1] then
        -- Lat2[4], Lon2[6] - NA
        SD[3], SD[5]  = GnssData.gga.latitude, GnssData.gga.longitude
        SD[9], SD[10] = GnssData.gga.alt, GnssData.gga.sat
    elseif not GnssData.warning.gns[1] then
        SD[3], SD[5]  = GnssData.gns.latitude, GnssData.gns.longitude
        SD[9], SD[10] = GnssData.gns.alt, GnssData.gns.sat
    elseif not GnssData.warning.locator[1] then
        SD[1], SD[2]  = os.date("%d%m%y"), os.date("%H%M%S", os.time(os.date("!*t"))) .. ".00"
        SD[3], SD[5]  = GnssData.gga.latitude, '0' .. GnssData.gga.longitude
    end
    if not GnssData.warning.vtg[1] then
        SD[7], SD[8]  = GnssData.vtg.speed, GnssData.vtg.course_t
    end
    SD[11] = checksum.crc16(table.concat(SD, ";") .. ';')
    return "#SD#" .. table.concat(SD, ";") .. "\r\n"
end

-- Extended Data package with CRC16
local function bigData(GnssData, optionalParams)
    local D = {"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","","NA","NA"}
    if not GnssData.warning.rmc[1] then
        D[1], D[2]  = GnssData.rmc.date, GnssData.rmc.utc
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
        D[1], D[2]  = os.date("%d%m%y"), os.date("%H%M%S", os.time(os.date("!*t"))) .. ".00"
        D[3], D[5]  = GnssData.gga.latitude, '0' .. GnssData.gga.longitude
    end
    if not GnssData.warning.vtg[1] then
        D[7], D[8]  = GnssData.vtg.speed, GnssData.vtg.course_t
    end

    for _,param in pairs(optionalParams) do
        D[16] = addOptional(D[16], param[1], param[2], param[3])
    end

    D[17] = checksum.crc16(table.concat(D, ";") .. ';')
    return "#D#" .. table.concat(D, ";") .. "\r\n"
end

-- Response from the server to the message
local function handlErr(resp)
	local ERROR_CODE = {
        ["#AL#1"]   = "OK",
        ["#ASD#1"]  = "OK",
        ["#AD#1"]   = "OK",
        ["#AL#0"]   = "Rejected connection",
        ["#AL#01"]  = "Password verification error",
        ["#AL#10"]  = "Checksum verification error",
        ["#ASD#-1"] = "Package structure error",
        ["#ASD#0"]  = "Incorrect time",
        ["#ASD#10"] = "Error getting coordinates",
        ["#ASD#11"] = "Error getting speed, course, or altitude",
        ["#ASD#12"] = "Error getting the number of satellites",
        ["#ASD#13"] = "Checksum verification error",
        ["#AD#-1"]  = "Package structure error",
        ["#AD#0"]   = "Incorrect time",
        ["#AD#10"]  = "Error getting coordinates",
        ["#AD#11"]  = "Error getting speed, course, or altitude",
        ["#AD#12"]  = "Error in getting the number of satellites or HDOP",
        ["#AD#13"]  = "Error getting Inputs or Outputs",
        ["#AD#14"]  = "Error receiving ADC",
        ["#AD#15"]  = "Error getting additional parameters",
        ["#AD#16"]  = "Checksum verification error"
    }

    for k, v in pairs(ERROR_CODE) do
        if k == resp then
            return v
        end
    end
    return "Unknown error"
end

-- Login Package
local function login(imei, pass)
    local L = {}
    L[1], L[2], L[3] = "2.0", imei, pass
    L[4] = checksum.crc16(table.concat(L, ";") .. ';')
    return "#L#" .. table.concat(L, ";") .. "\r\n"
end

-- Send data to server side
function wialon_ips.sendData(GnssData, serverConfig, optionalParams)
    local r, s, e
    local DATA_OK    = "OK"
    local err        = {false, DATA_OK}
    local wialonData = bigData(GnssData, optionalParams)

    -- Data is missing, there is nothing to send
    if string.find(wialonData, "DB2D") then
        return {true, "No data to send"}
    end

    s, e = tcp:connect(serverConfig.address, serverConfig.port)
    if not s then
        blackbox.set(GnssData, serverConfig)
        tcp:close()
        return {true, e}
    end
    tcp:settimeout(2)
    tcp:send(login(serverConfig.login, serverConfig.password) .. '\n')
    r, e = tcp:receive()

    if handlErr(r) == DATA_OK then
        tcp:send(wialonData)
        r, e = tcp:receive()
        if handlErr(r) == DATA_OK then
            local booferSize, booferData = blackbox.get(serverConfig)
            if booferSize > 0 then
                tcp:send(booferData .. '\n')
                r, e = tcp:receive()
                local sentSize = string.gsub(r, "%D", "")
                if tonumber(sentSize) and tonumber(sentSize) >= booferSize then
                    blackbox.clean(serverConfig)
                end
            end
        elseif handlErr(r) ~= DATA_OK then
            blackbox.set(GnssData, serverConfig)
        end
    else
        err = {true, handlErr(r)}
        blackbox.set(GnssData, serverConfig)
    end

    tcp:close()
    return err
end

return wialon_ips