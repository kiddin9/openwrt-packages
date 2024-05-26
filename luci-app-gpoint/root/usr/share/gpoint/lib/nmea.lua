-------------------------------------------------------------
-- This module is designed to extract data from NMEA messages. 
-- All data is combined into a table "GnssData".
-------------------------------------------------------------
-- Copyright 2021-2023 Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0

local uci = require("luci.model.uci")
local serial = require("serial")
local checksum = require("checksum")
local nixio = require("nixio.fs")

local nmea = {}

-- Table for navigation data
local function createGnssForm()
    local GnssForm = {
        warning = {
            app = { true, "" },
            gga = { true, "" },
            rmc = { true, "" },
            vtg = { true, "" },
            gsa = { true, "" },
            gp = { true, "" },
            gns = { true, "" },
            server = { true, "" },
            locator = { true, "" },
            geofence = { true, "" }
        },
        gp = { longitude = "-", latitude = "-" },
        gga = { longitude = "-", latitude = "-" }
    }
    return GnssForm
end

--Converting coordinates from the NMEA protocol to degrees
local function nmeaCoordinatesToDouble(coord, quadrant)
    local deg = math.floor(coord / 100)
    local coord_deg = deg + (coord - 100 * deg) / 60
    if quadrant == 'W' or quadrant == 'S' then
        return coord_deg * -1
    end
    return coord_deg
end

--We are looking for the desired data line in the line received from the device
local function findInResp(data, begin)
    local err = true
    local b = string.find(data, begin)
    local e = string.find(data, "\r\n", b)

    if b and e then
        err = false
    else
        b, e = nil, nil
    end
    return err, b, e
end

-- message parsing, checksum checking
local function getCropData(data, msg)
    local err, b, e = findInResp(data, msg)
    if not err then
        data = string.gsub(string.sub(data, b, e), '%c', "")
        if checksum.crc8(data) then
            data = string.gsub(data, msg, '', 1)
            data = string.gsub(data, "*%d+%w+", '', 1)
            err = { false, "OK" }
        else
            err = { true, "Checksum error" }
            data = nil
        end
    else
        err = { true, "No data found" }
        data = nil
    end
    return err, data
end

-- Creating a table with data before adding data to a single space
function doTable(data, keys)
    local parseData = {}

    while string.find(data, ',,') do
        data = string.gsub(data, ',,', ",-,")
    end

    if string.sub(data, 1, 1) == ',' then
        data = '-' .. data
    end

    local i = 1
    for val in string.gmatch(data, "[^,]+") do
        parseData[keys[i]] = val
        i = i + 1
    end
    return parseData
end

-- The function of searching the time zone by the received coordinates
local function findTimeZone(time, date, lon)
    local datetime = { year, month, day, hour, min, sec }
    local timeZone = uci:get("gpoint", "modem_settings", "timezone")

    -- calculate the time zone by coordinates
    if timeZone == nil or timeZone == "auto" then
        timeZone = math.floor((tonumber(lon) + (7.5 * (tonumber(lon) > 0 and 1.0 or -1.0))) / 15.0)
    end

    datetime.hour, datetime.min, datetime.sec = string.match(time, "(%d%d)(%d%d)(%d%d)")
    datetime.day, datetime.month, datetime.year = string.match(date, "(%d%d)(%d%d)(%d%d)")
    datetime.year = "20" .. datetime.year -- Someone change this to 21 in the 2100 year

    --we request the unix time and then add the time zone
    local unix = os.time(datetime)
    unix = unix + ((math.floor(tonumber(timeZone) * 100)) % 100) * 36
    return unix + math.floor(tonumber(timeZone)) * 3600
end

-- Add 0 for the time and date values if < 10
local function addZero(val)
    return tonumber(val) > 9 and tostring(val) or '0' .. tostring(val)
end

-- If there is no data, the default values of the table are dashed
local function addDash(data)
    local dashData = {}
    for i = 1, #data do
        dashData[data[i]] = '-'
    end
    return dashData
end

---------------------------------------------------------------------------------------------------------------
-- GGA - Global Positioning System Fix Data
local function getGGA(GnssData, resp)
    GnssData.gga = {
        "utc", -- UTC of this position report, hh is hours, mm is minutes, ss.ss is seconds.
        "latitude", -- Latitude, dd is degrees, mm.mm is minutes
        "ns", -- N or S (North or South)
        "longitude", -- Longitude, dd is degrees, mm.mm is minutes
        "ew", -- E or W (East or West)
        "qual", -- GPS Quality Indicator (non null)
        "sat", -- Number of satellites in use, 00 - 12
        "hdp", -- Horizontal Dilution of precision (meters)
        "alt", -- Antenna Altitude above/below mean-sea-level (geoid) (in meters)
        "ualt", -- Units of antenna altitude, meters
        "gsep", -- Geoidal separation, the difference between the WGS-84 earth ellipsoid and mean-sea-level
        "ugsep", -- Units of geoidal separation, meters
        "age", -- Age of differential GPS data, time in seconds since last SC104 type 1 or 9 update, null field when DGPS is not used
        "drs"         -- Differential reference station ID, 0000-1023
    }

    local err, gga = getCropData(resp, "$GPGGA,")
    if not err[1] and string.gsub(gga, ',', '') ~= '0'
            and string.sub(gga, string.find(gga, ',') + 1, string.find(gga, ',') + 1) ~= ',' then
        GnssData.gga = doTable(gga, GnssData.gga)
        GnssData.warning.gga = { false, "OK" }
    else
        GnssData.gga = addDash(GnssData.gga)
        GnssData.warning.gga = err[1] and err or { true, "Bad GGA data" }
    end
end

-- RMC - Recommended Minimum Navigation Information
local function getRMC(GnssData, resp)
    GnssData.rmc = {
        "utc", -- UTC of position fix, hh is hours, mm is minutes, ss.ss is seconds.
        "valid", -- Status, A = Valid, V = Warning
        "latitude", -- Latitude, dd is degrees. mm.mm is minutes.
        "ns", -- N or S
        "longitude", -- Longitude, ddd is degrees. mm.mm is minutes.
        "ew", -- E or W
        "knots", -- Speed over ground, knots
        "tmgdt", -- Track made good, degrees true
        "date", -- Date, ddmmyy
        "mv", -- Magnetic Variation, degrees
        "ewm", -- E or W
        "nstat", -- Nav Status (NMEA 4.1 and later) A=autonomous, D=differential, E=Estimated, ->
        -- M=Manual input mode N=not valid, S=Simulator, V = Valid
        "sc"            --checksum
    }

    local err, rmc = getCropData(resp, "$GPRMC,")
    if not err[1] and string.find(rmc, ",A,") then
        GnssData.rmc = doTable(rmc, GnssData.rmc)
        GnssData.warning.rmc = { false, "OK" }
    else
        GnssData.rmc = addDash(GnssData.rmc)
        GnssData.warning.rmc = err[1] and err or { true, "Bad RMC data" }
    end
end

-- VTG - Track made good and Ground speed
local function getVTG(GnssData, resp)
    GnssData.vtg = {
        "course_t", -- Course over ground, degrees True
        't', -- T = True
        "course_m", -- Course over ground, degrees Magnetic
        'm', -- M = Magnetic
        "knots", -- Speed over ground, knots
        'n', -- N = Knots
        "speed", -- Speed over ground, km/hr
        'k', -- K = Kilometers Per Hour
        "faa"          -- FAA mode indicator (NMEA 2.3 and later)
    }

    local err, vtg = getCropData(resp, "$GPVTG,")
    if not err[1] and (string.find(vtg, 'A') or string.find(vtg, 'D')) then
        GnssData.vtg = doTable(vtg, GnssData.vtg)
        GnssData.warning.vtg = { false, "OK" }
    else
        GnssData.vtg = addDash(GnssData.vtg)
        GnssData.warning.vtg = err[1] and err or { true, "Bad VTG data" }
    end
end

--GSA - GPS DOP and active satellites
local function getGSA(GnssData, resp)
    GnssData.gsa = {
        "smode", -- Selection mode: M=Manual, forced to operate in 2D or 3D, A=Automatic, 2D/3D
        "mode", -- Mode (1 = no fix, 2 = 2D fix, 3 = 3D fix)
        "id1", -- ID of 1st  satellite used for fix
        "id2", -- ID of 2nd  satellite used for fix
        "id3", -- ID of 3rd  satellite used for fix
        "id4", -- ID of 4th  satellite used for fix
        "id5", -- ID of 5th  satellite used for fix
        "id6", -- ID of 6th  satellite used for fix
        "id7", -- ID of 7th  satellite used for fix
        "id8", -- ID of 8th  satellite used for fix
        "id9", -- ID of 9th  satellite used for fix
        "id10", -- ID of 10th satellite used for fix
        "id11", -- ID of 11th satellite used for fix
        "id12", -- ID of 12th satellite used for fix
        "pdop", -- PDOP
        "hdop", -- HDOP
        "vdop", -- VDOP
        "sc"         -- checksum
    }

    local err, gsa = getCropData(resp, "$GPGSA,")
    if not err[1] and string.find(gsa, '2') then
        GnssData.gsa = doTable(gsa, GnssData.gsa)
        GnssData.warning.gsa = { false, "OK" }
    else
        GnssData.gsa = addDash(GnssData.gsa)
        GnssData.warning.gsa = err[1] and err or { true, "Bad GSA data" }
    end
end

--GNS - GLONAS Fix data
local function getGNS(GnssData, resp)
    GnssData.gns = {
        "utc", -- UTC of this position report, hh is hours, mm is minutes, ss.ss is seconds.
        "latitude", -- Latitude, dd is degrees, mm.mm is minutes
        "ns", -- N or S (North or South)
        "longitude", -- Longitude, dd is degrees, mm.mm is minutes
        "ew", -- E or W (East or West)
        "mi", -- Mode indicator (non-null)
        "sat", -- Total number of satellites in use, 00-99
        "hdp", -- Horizontal Dilution of Precision, HDOP
        "alt", -- Antenna Altitude above/below mean-sea-level (geoid) (in meters)
        "gsep", -- Goeidal separation meters
        "age", -- Age of differential data
        "drs", -- Differential reference station ID
        "nstat"      --Navigational status (optional) S = Safe C = Caution U = Unsafe V = Not valid for navigation
    }

    local err, gns = getCropData(resp, "$GNGNS,")
    if not err[1] and string.gsub(gns, ',', '') ~= '0' and not string.find(gns, "NNN") then
        GnssData.gns = doTable(gns, GnssData.gns)
        GnssData.warning.gns = { false, "OK" }
    else
        GnssData.gns = addDash(GnssData.gns)
        GnssData.warning.gns = err[1] and err or { true, "Bad GNS data" }
    end
end

-- Prepares data for the web application (Some custom data)
local function getGPoint(GnssData, resp)
    GnssData.gp = {
        longitude = '-',
        latitude = '-',
        altitude = '-',
        utc = '-',
        date = '-',
        nsat = '-',
        hdop = '-',
        cog = '-',
        spkm = '-',
        unix = '-'
    }

    local err = { true, "" }
    local GpsOrGlonas = false

    if not GnssData.warning.gga[1] then
        GpsOrGlonas = GnssData.gga
    elseif not GnssData.warning.gns[1] then
        GpsOrGlonas = GnssData.gns
    else
        err[2] = "GGA: " .. GnssData.warning.gga[2] .. ' ' .. "GNS: " .. GnssData.warning.gns[2] .. ' '
    end

    if GpsOrGlonas then
        GnssData.gp.latitude = string.format("%0.6f", nmeaCoordinatesToDouble(GpsOrGlonas.latitude, GpsOrGlonas.ns))
        GnssData.gp.longitude = string.format("%0.6f", nmeaCoordinatesToDouble(GpsOrGlonas.longitude, GpsOrGlonas.ew))
        GnssData.gp.altitude = GpsOrGlonas.alt
        GnssData.gp.nsat = GpsOrGlonas.sat
        GnssData.gp.hdop = GpsOrGlonas.hdp
    end

    if not GnssData.warning.vtg[1] then
        GnssData.gp.cog = GnssData.vtg.course_t
        GnssData.gp.spkm = GnssData.vtg.speed
    else
        err[2] = err[2] .. "VTG: " .. GnssData.warning.vtg[2] .. ' '
    end

    if not GnssData.warning.rmc[1] then
        local unixTime = findTimeZone(GnssData.rmc.utc, GnssData.rmc.date, nmeaCoordinatesToDouble(GnssData.rmc.longitude, GnssData.rmc.ew))
        local dateTime = os.date("*t", unixTime)

        GnssData.gp.utc = string.format("%s:%s", addZero(dateTime.hour), addZero(dateTime.min))
        GnssData.gp.date = string.format("%s.%s.%d", addZero(dateTime.day), addZero(dateTime.month), dateTime.year)
        GnssData.gp.unix = unixTime
    else
        err[2] = err[2] .. "RMC: " .. GnssData.warning.rmc[2]
    end

    if GnssData.warning.gga[1] and GnssData.warning.gns[1] and GnssData.warning.vtg[1] and GnssData.warning.rmc[1] then
        err = { false, "Updating data..." }
    end

    if err[2] == "" then
        err = { false, "OK" }
    end

    GnssData.warning.gp = err
end

------------------------------------------------------
-- Get a certain kind of NMEA data (data parsing)
------------------------------------------------------

function nmea.getData(line, port)
    GnssData = createGnssForm()
    GnssData.warning.app, resp = serial.read(port)

    if line == "GP" then
        getGGA(GnssData, resp)
        getGNS(GnssData, resp)
        getRMC(GnssData, resp)
        getVTG(GnssData, resp)
        getGPoint(GnssData, resp)
    elseif line == "GGA" then
        getGGA(GnssData, resp)
    elseif line == "GNS" then
        getGNS(GnssData, resp)
    elseif line == "RMC" then
        getRMC(GnssData, resp)
    elseif line == "VTG" then
        getVTG(GnssData, resp)
    elseif line == "GSA" then
        getGSA(GnssData, resp)
    else
        GnssData.warning.app = { true, "Bad argument..." }
    end
    return GnssData
end

------------------------------------------------------
-- parsing all NMEA data
------------------------------------------------------

function nmea.getAllData(modemConfig)
    GnssData = createGnssForm()
    GnssData.warning.app, resp = serial.read(modemConfig.port)

    getGGA(GnssData, resp)
    getGNS(GnssData, resp)
    getRMC(GnssData, resp)
    getVTG(GnssData, resp)
    getGSA(GnssData, resp) -- rarely used
    getGPoint(GnssData, resp)

    return GnssData
end

function nmea.startGNSS(port, command)
    local p = tonumber(string.sub(port, #port))
    p = p > 2 and p - 1 or p + 1
    p = string.gsub(port, '%d', tostring(p))
    local error, resp = true, {
        warning = {
            app = { true, "Port is unavailable. Check the modem connections!" },
            locator = {},
            server = {}
        }
    }
    if command ~= '-' then
        local fport = nixio.glob("/dev/tty[A-Z][A-Z]*")
        for name in fport do
            if string.find(name, p) then
                error, resp = serial.write(p, command)
            end
        end
    else
        error, resp = false, { warning = { app = { false, "GOOD!" }, locator = {}, server = {} } }
    end
    return error, resp
end

return nmea