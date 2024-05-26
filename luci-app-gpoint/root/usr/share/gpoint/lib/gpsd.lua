-------------------------------------------------------------
-- luci-app-gpoint. Gnss information dashboard for 3G/LTE dongle.
-------------------------------------------------------------
-- Copyright 2021-2023 Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0

local socket = require("socket")
local tcp = assert(socket.tcp())
local json = require("luci.jsonc")
local uci = require("luci.model.uci")
local nixio = require("nixio.fs")
local serial = require("serial")

gpsd = {}

local function createGnssForm()
    return { warning = { app = { true, "" }, gga = { true, "" }, rmc = { true, "" }, vtg = { true, "" },
                         gsa = { true, "not use" }, gp = { true, "" }, gns = { true, "not use" },
                         server = { true, "" }, locator = { true, "" } },
             gp = { hdop = '-', utc = '-', date = '-', spkm = '-', altitude = '-', unix = '-',
                    longitude = '-', latitude = '-', cog = '-', nsat = '-' },
             gga = { latitude = '-', longitude = '-', alt = '-', sat = '-' },
             vtg = { speed = '-', course_t = '-' },
             rmc = { date = '-', utc = '-' },
             gns = { longitude = '-', latitude = '-' } }
end

local function addZero(val)
    return tonumber(val) > 9 and tostring(val) or '0' .. tostring(val)
end

local function findTimeZone(time, date)
    local datetime = { year, month, day, hour, min, sec }
    local timeZone = uci:get("gpoint", "modem_settings", "timezone")

    -- calculate the time zone by coordinates
    if timeZone == nil or timeZone == "auto" then
        timeZone = 0
    end

    datetime.hour, datetime.min, datetime.sec = string.match(time, "(%d%d)(%d%d)(%d%d)")
    datetime.day, datetime.month, datetime.year = string.match(date, "(%d%d)(%d%d)(%d%d)")
    datetime.year = "20" .. datetime.year -- Someone change this to 21 in the 2100 year

    --we request the unix time and then add the time zone
    local unix = os.time(datetime)
    unix = unix + ((math.floor(tonumber(timeZone) * 100)) % 100) * 36
    return unix + math.floor(tonumber(timeZone)) * 3600
end

local function degreesToNmea(coord)
    local degrees = math.floor(coord)
    coord = math.abs(coord) - degrees
    local sign = coord < 0 and "-" or ""
    return sign .. string.format("%02i%02.5f", degrees, coord * 60.00)
end

local function connectToGspd(ip, port)
    local s, e, status, partial, err
    s, e = tcp:connect(ip, port)
    tcp:settimeout(0.1)
    tcp:send("?WATCH={\"enable\":true,\"json\":true};\r\n")
    tcp:receive('*a')
    tcp:send("?POLL;")
    s, status, partial = tcp:receive('*a')
    tcp:close()

    err = { false, "OK" }
    if status == "closed" then
        err = { true, "Socket closed" }
        partial = nil
    end
    return err, partial
end

function gpsd.getAllData(modemConfig)
    GnssData = createGnssForm()
    GnssData.warning.app, gnssReq = connectToGspd(modemConfig.gpsd_ip, tonumber(modemConfig.gpsd_port))
    if GnssData.warning.app[1] then
        return GnssData
    end

    gnssReq = json.parse(gnssReq)
    if gnssReq == nil or gnssReq.tpv == nil or gnssReq.sky == nil or gnssReq.sky[1] == nil
            or gnssReq.tpv[1] == nil or gnssReq.tpv[1].mode == nil or gnssReq.tpv[1].mode == 1 then
        for _, i in pairs(GnssData.warning) do
            i[2] = "Gnss data not found"
        end
        return GnssData
    end


    -- FOR GP --
    GnssData.gp.hdop = string.format("%0.2f", tostring(gnssReq.sky[1].hdop))
    GnssData.gp.date = string.gsub(string.sub(gnssReq.tpv[1].time, 1, string.find(gnssReq.tpv[1].time, 'T') - 1), '-', '')
    GnssData.gp.spkm = tostring(modemConfig.gpsd_speed == '0' and gnssReq.tpv[1].speed * 3.6 or gnssReq.tpv[1].speed)
    GnssData.gp.altitude = string.format("%0.1f", tostring(gnssReq.tpv[1].alt))
    GnssData.gp.unix = string.gsub(string.sub(gnssReq.tpv[1].time, string.find(gnssReq.tpv[1].time, 'T') + 1, string.len(gnssReq.tpv[1].time) - 1), ':', '')
    GnssData.gp.longitude = string.format("%0.6f", tostring(gnssReq.tpv[1].lon))
    GnssData.gp.latitude = string.format("%0.6f", tostring(gnssReq.tpv[1].lat))
    GnssData.gp.cog = tostring(gnssReq.tpv[1].track)
    GnssData.gp.nsat = tostring(gnssReq.sky[1].nSat)

    GnssData.gp.date = string.sub(GnssData.gp.date, 7, 8) .. string.sub(GnssData.gp.date, 5, 6) .. string.sub(GnssData.gp.date, 3, 4)

    -- FOR GGA --
    GnssData.gga.latitude = degreesToNmea(gnssReq.tpv[1].lat)
    GnssData.gga.longitude = degreesToNmea(gnssReq.tpv[1].lon)
    GnssData.gga.alt = GnssData.gp.altitude
    GnssData.gga.sat = GnssData.gp.nsat

    -- FOR VTG --
    GnssData.vtg.speed = GnssData.gp.spkm
    GnssData.vtg.course_t = GnssData.gp.cog

    --FOR RMC --
    GnssData.rmc.date = GnssData.gp.date
    GnssData.rmc.utc = GnssData.gp.unix

    local unixTime = findTimeZone(GnssData.gp.unix, GnssData.gp.date)
    local dateTime = os.date("*t", unixTime)

    GnssData.gp.utc = string.format("%s:%s", addZero(dateTime.hour), addZero(dateTime.min))
    GnssData.gp.date = string.format("%s.%s.%d", addZero(dateTime.day), addZero(dateTime.month), dateTime.year)
    GnssData.gp.unix = unixTime

    for _, i in pairs(GnssData.warning) do
        i[1] = false
        i[2] = "OK"
    end
    gnssReq = nil
    return GnssData
end

function gpsd.startGNSS(port, command)
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

return gpsd
