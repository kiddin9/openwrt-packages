common_path = '/usr/share/gpoint/tests/luaunitlib/?.lua;'
package.path = common_path .. package.path

lu = require('luaunit')
----------------------------------------------------------------------------
-- nmea test

-- Bitxor
-- checkcrc
-- getcropdata
----------------------------------------------------------------------------

function createGnssForm()
	local GnssData = {
		warning = {app, gga, rmc, vtg, gsa, gp}
	}
	return GnssData
end
-- To calculate the checksum
-- Bitwise xor
local function BitXOR(a, b)
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra ~= rb then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end

    if a < b then a = b end
    while a > 0 do
        local ra = a % 2
        if ra > 0 then c = c + p end
        a, p = (a - ra) / 2, p * 2
    end
    return c
end

-- To calculate the checksum
function decimalToHex(num)
    if num == 0 then
        return '0'
    end

    local neg = false
    if num < 0 then
        neg = true
        num = num * -1
    end

    local hexstr = "0123456789ABCDEF"
    local result = ""
    while num > 0 do
        local n = math.mod(num, 16)
        result = string.sub(hexstr, n + 1, n + 1) .. result
        num = math.floor(num / 16)
    end

    if neg then
        result = '-' .. result
    end
    return result
end

-- Сalculate the checksum (CRC-8)
function checkCRC(data)
	local crc8 = string.sub(data,  #data - 1)
	data = string.sub(data, 2, #data - 3)

	local b_sum = string.byte(data, 1)
	for i = 2, #data do
		b_sum = BitXOR(b_sum, string.byte(data, i))
	end

	return decimalToHex(b_sum) == crc8 and true or false
end

--Converting coordinates from the NMEA protocol to degrees
function nmeaCoordinatesToDouble(coord)
	local deg = math.floor(coord / 100)
	return deg + (coord - 100 * deg) / 60
end

--We are looking for the desired data line in the line received from the device
function findInResp(data, begin)
	local err = true
	local b = string.find(data, begin)
	local e = string.find(data, "\r\n", b)

	if b and e then
		err = false
	else
		b = nil
		e = nil
	end
	return err, b, e
end

function getCropData(data, msg)
	local err, b, e = findInResp(data, msg)
	if not err then
		data = string.gsub(string.sub(data, b, e), '%c', "")
		if checkCRC(data) then
			data = string.gsub(data, msg, '', 1)
			data = string.gsub(data, "*%d+%w+", '', 1)
			err = {false, "OK"}
		else
			err  = {true, "Checksum error"}
			data = nil
		end
	else
		err = {true, "No data found"}
		data = nil
	end
	return err, data
end

-- Creating a table with data before adding data to a single space
function doTable(data, keys)
	local tabl = {}

	while string.find(data, ',,') do
		data = string.gsub(data, ',,', ",-,")
	end

	local i = 1
	for val in string.gmatch(data, "[^,]+") do
		tabl[keys[i]] = val
		i = i + 1
	end
	return tabl
end

-- The function of searching the time zone by the received coordinates
function findTimeZone(time, date, lon)
	local datetime = { year,month,day,hour,min,sec }
	-- calculate the time zone by coordinates
	local timeZone = math.floor((tonumber(lon) + (7.5 * (tonumber(lon) > 0 and 1.0 or -1.0))) / 15.0)

	datetime.hour, datetime.min, datetime.sec   = string.match(time, "(%d%d)(%d%d)(%d%d)")
	datetime.day, datetime.month, datetime.year = string.match(date,"(%d%d)(%d%d)(%d%d)")
	datetime.year = "20" .. datetime.year -- Someone change this to 21 in the 2100 year

	--we request the unix time and then add the time zone
	local unix = os.time(datetime)
	unix = unix + ((math.floor(timeZone* 100)) % 100) * 36
    unix = unix + math.floor(timeZone)  * 3600

    return os.date("*t", unix)
end
-- Add 0 for the time and date values if < 10
function addZero(val)
	return tonumber(val) > 9 and tostring(val) or '0' .. tostring(val)
end

---------------------------------------------------------------------------------------------------------------
-- GGA - Global Positioning System Fix Data
function getGGA(resp)
	local err, gga = getCropData(resp, "$GPGGA,")
	if not err[1] then
		local ggakeys = {
			"utc",       -- UTC of this position report, hh is hours, mm is minutes, ss.ss is seconds.
			"latitude",  -- Latitude, dd is degrees, mm.mm is minutes
			"ne", 		 -- N or S (North or South)
			"longitude", -- Longitude, dd is degrees, mm.mm is minutes
			"ew",        -- E or W (East or West)
			"qual",      -- GPS Quality Indicator (non null)
			"sat",       -- Number of satellites in use, 00 - 12
			"hdp",       -- Horizontal Dilution of precision (meters)
			"alt", 		 -- Antenna Altitude above/below mean-sea-level (geoid) (in meters)
			"ualt",		 -- Units of antenna altitude, meters
			"gsep", 	 -- Geoidal separation, the difference between the WGS-84 earth ellipsoid and mean-sea-level
			"ugsep", 	 -- Units of geoidal separation, meters
			"age", 		 -- Age of differential GPS data, time in seconds since last SC104 type 1 or 9 update, null field when DGPS is not used
			"drs" 		 -- Differential reference station ID, 0000-1023
		}

		if string.gsub(gga, ',', '') ~= '0' then
			gga = doTable(gga, ggakeys)
		else
			err = {true, "Bad GGA data"}
			gga = nil
		end
	end
	return err, gga
end

-- RMC - Recommended Minimum Navigation Information
function getRMC(resp)
	local err, rmc = getCropData(resp, "$GPRMC,")
	if not err[1] then
		local rmckeys = {
			"utc",       -- UTC of position fix, hh is hours, mm is minutes, ss.ss is seconds.
			"valid",     -- Status, A = Valid, V = Warning
			"latitude",  -- Latitude, dd is degrees. mm.mm is minutes.
			"ns",        -- N or S
			"longitude", -- Longitude, ddd is degrees. mm.mm is minutes.
			"ew",        -- E or W
			"knots",     -- Speed over ground, knots
			"tmgdt",     -- Track made good, degrees true
			"date",      -- Date, ddmmyy
			"mv",        -- Magnetic Variation, degrees
			"ewm",       -- E or W
			"nstat"      -- Nav Status (NMEA 4.1 and later) A=autonomous, D=differential, E=Estimated, -> 
						 -- -> M=Manual input mode N=not valid, S=Simulator, V = Valid
		}

		if not string.find(rmc, 'V') then
			rmc = doTable(rmc, rmckeys)
		else
			err = {true, "Bad RMC data"}
			rmc = nil
		end
	end
	return	err, rmc
end

-- VTG - Track made good and Ground speed
function getVTG(resp)
	local err, vtg = getCropData(resp, "$GPVTG,")
	if not err[1] then
		local vtgkeys = {
			"course_t",   -- Course over ground, degrees True
			't',		  -- T = True
			"course_m",   -- Course over ground, degrees Magnetic
			'm',		  -- M = Magnetic
			"knots",	  -- Speed over ground, knots
			'n',		  -- N = Knots
			"speed",	  -- Speed over ground, km/hr
			'k',		  -- K = Kilometers Per Hour
			"faa"		  -- FAA mode indicator (NMEA 2.3 and later)
		}

		if string.find(vtg, 'A') or string.find(vtg, 'D') then
			vtg = doTable(vtg, vtgkeys)
		else
			err = {true, "Bad VTG data"}
			vtg = nil
		end
	end
	return	err, vtg
end

--GSA - GPS DOP and active satellites
function getGSA(resp)
	local err, gsa = getCropData(resp, "$GPGSA,")
	if not err[1] then
		local gsakeys = {
			"smode",	  -- Selection mode: M=Manual, forced to operate in 2D or 3D, A=Automatic, 2D/3D
			"mode",		  -- Mode (1 = no fix, 2 = 2D fix, 3 = 3D fix)
			"id1",        -- ID of 1st  satellite used for fix
			"id2",        -- ID of 2nd  satellite used for fix
			"id3",        -- ID of 3rd  satellite used for fix
			"id4",        -- ID of 4th  satellite used for fix
			"id5",        -- ID of 5th  satellite used for fix
			"id6",        -- ID of 6th  satellite used for fix
			"id7",        -- ID of 7th  satellite used for fix
			"id8",		  -- ID of 8th  satellite used for fix
			"id9",        -- ID of 9th  satellite used for fix
			"id10",       -- ID of 10th satellite used for fix
			"id11",       -- ID of 11th satellite used for fix
			"id12",       -- ID of 12th satellite used for fix
			"pdop",       -- PDOP
			"hdop",       -- HDOP
			"vdop"        -- VDOP
		}

		if string.find(gsa, '2') then
			gsa = doTable(gsa, gsakeys)
		else
			err = {true, "Bad GSA data"}
			gsa = nil
		end
	end
	return err, gsa
end

function parseAllData(resp)
	local GnssData = createGnssForm()
	GnssData.warning.gga, GnssData["GGA"] = getGGA(resp)
	GnssData.warning.rmc, GnssData["RMC"] = getRMC(resp)
	GnssData.warning.vtg, GnssData["VTG"] = getVTG(resp)
	GnssData.warning.gsa, GnssData["GSA"] = getGSA(resp)
	return GnssData
end

-- This function prepares data for the web application (Some custom data)
function getGPoint(resp)
	
	local web = {
		longitude = '-', 
		latitude  = '-', 
		altitude  = '-', 
		utc       = '-', 
		date      = '-', 
		nsat      = '-', 
		hdop      = '-', 
		cog       = '-', 
		spkm      = '-'
	}

	local GnssData = parseAllData(resp)
	local err = {true, ""}

	if not GnssData.warning.gga[1] then
		web.latitude   = string.format("%0.6f", nmeaCoordinatesToDouble(GnssData.GGA.latitude))
		web.longitude  = string.format("%0.6f",nmeaCoordinatesToDouble(GnssData.GGA.longitude))
		web.altitude   = GnssData.GGA.alt 
		web.nsat       = GnssData.GGA.sat
		web.hdop       = GnssData.GGA.hdp
	else
		err[2] = "GGA: " .. GnssData.warning.gga[2] .. ' '
	end

	if not GnssData.warning.vtg[1] then
		web.cog        = GnssData.VTG.course_t
		web.spkm	   = GnssData.VTG.speed
	else
		err[2] = err[2] .. "VTG: " .. GnssData.warning.vtg[2] .. ' '
	end

	if not GnssData.warning.rmc[1] then
		local dateTime = findTimeZone(GnssData.RMC.utc, GnssData.RMC.date, nmeaCoordinatesToDouble(GnssData.RMC.longitude))

		web.utc = string.format("%s:%s", addZero(dateTime.hour), addZero(dateTime.min))
		web.date = string.format("%s.%s.%d", addZero(dateTime.day), addZero(dateTime.month), dateTime.year)
	else
		err[2] = err[2] .. "RMC: " .. GnssData.warning.vtg[2]
	end

	if GnssData.warning.gga[1] and GnssData.warning.vtg[1] and GnssData.warning.rmc[1] then
		err[2] = "Updating data..."
	else
		err = {false, "OK"}
	end

	return err, web
end

-----------------------------------------------------------------------------------
-- public
-----------------------------------------------------------------------------------

function getData(line, port)
	local err, resp = serial.read(port)
	local GnssData = createGnssForm()
	if err[1] then
		GnssData.warning.app = {true, err[2]}
		return GnssData
	end

	GnssData.warning.app = {false, "OK"}

	if line == "GP" then
		GnssData.warning.gp,  GnssData["gp"]  = getGPoint(resp)
	elseif line == "GGA" then
		GnssData.warning.gga, GnssData["gga"] = getGGA(resp)
	elseif line == "RMC" then
		GnssData.warning.rmc, GnssData["rmc"] = getRMC(resp)
	elseif line == "VTG" then
		GnssData.warning.vtg, GnssData["vtg"] = getVTG(resp)
	elseif line == "GSA" then
		GnssData.warning.gsa, GnssData["gsa"] = getGSA(resp)
	else
		GnssData.warning.app = {true, "Bad argument..."}
	end
	return GnssData
end

function getAllData(port)
	local err, resp = serial.read(port)
	local GnssData = createGnssForm()
	if err[1] then
		GnssData.warning.app = {true, err[2]}
		return GnssData
	end

	GnssData = parseAllData(resp)
	GnssData.warning.gp, GnssData["gp"] = getGPoint(resp)
	GnssData.warning.app = {false, "OK"}
	return GnssData
end

------------------------------------------------------------------------------

local goodGNSSSdata = {
	"$GPRMC,113702.568,V,4154.931,N,08002.497,W,95.5,0.02,220721,,E*4E",
	"$GPGGA,113703.568,4154.931,N,08002.497,W,0,00,,,M,,M,,*52",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.1,0.8,0.6*3F",
	"$GPRMC,113705.568,V,4154.933,N,08002.497,W,86.0,-0.05,220721,,E*66",
	"$GPGGA,113706.568,4154.933,N,08002.497,W,0,00,0.8,,M,,M,,*73",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.2,0.0,0.4*36",
	"$GPRMC,113708.568,V,4154.935,N,08002.498,W,55.1,-0.10,220721,,E*69",
	"$GPGGA,113709.568,4154.935,N,08002.498,W,0,00,0.0,,M,,M,,*7D",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.7,0.2,0.8*3C",
	"$GPRMC,113711.568,V,4154.937,N,08002.498,W,95.0,-0.10,220721,,E*6E",
	"$GPGGA,113712.568,4154.937,N,08002.498,W,0,00,0.2,,M,,M,,*77",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.7,0.6,0.3*32",
	"$GPRMC,113714.568,V,4154.939,N,08002.498,W,28.0,-0.07,220721,,E*65",
	"$GPGGA,113715.568,4154.939,N,08002.498,W,0,00,0.6,,M,,M,,*7A",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,1.0,1.0,0.5*34",
	"$GPRMC,113717.568,V,4154.940,N,08002.498,W,30.1,0.03,220721,,E*49",
	"$GPGGA,113718.568,4154.940,N,08002.498,W,0,00,1.0,,M,,M,,*7E",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.5,0.1,0.2*36",
	"$GPRMC,113720.568,V,4154.942,N,08002.498,W,0.2,-0.02,220721,,E*53",
	"$GPGGA,113721.568,4154.942,N,08002.498,W,0,00,0.1,,M,,M,,*76",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.2,0.5,0.7*30",
	"$GPRMC,113723.568,V,4154.944,N,08002.498,W,53.6,0.05,220721,,E*4E",
	"$GPGGA,113724.568,4154.944,N,08002.498,W,0,00,0.5,,M,,M,,*71",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,1.0,0.6,0.1*37",
	"$GPRMC,113726.568,V,4154.946,N,08002.498,W,76.6,0.04,220721,,E*4F",
	"$GPGGA,113727.568,4154.946,N,08002.498,W,0,00,0.6,,M,,M,,*73",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.2,0.3,0.7*37",
	"$GPRMC,113729.568,V,4154.948,N,08002.497,W,30.9,0.12,220721,,E*4B",
	"$GPGGA,113730.568,4154.948,N,08002.497,W,0,00,0.3,,M,,M,,*71",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.5,0.2,0.2*34",
	"$GPRMC,113732.568,V,4154.949,N,08002.497,W,47.2,0.20,220721,,E*4A",
	"$GPGGA,113733.568,4154.949,N,08002.497,W,0,00,0.2,,M,,M,,*72",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.3,0.8,0.2*39",
	"$GPRMC,113735.568,V,4154.951,N,08002.496,W,31.1,0.13,220721,,E*47",
	"$GPGGA,113736.568,4154.951,N,08002.496,W,0,00,0.8,,M,,M,,*75",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.2,0.6,0.1*35",
	"$GPRMC,113738.568,V,4154.953,N,08002.496,W,58.2,0.10,220721,,E*47",
	"$GPGGA,113739.568,4154.953,N,08002.496,W,0,00,0.6,,M,,M,,*76",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.6,0.9,0.7*39",
	"$GPRMC,113741.568,V,4154.955,N,08002.496,W,88.3,0.03,220721,,E*41",
	"$GPGGA,113742.568,4154.955,N,08002.496,W,0,00,0.9,,M,,M,,*73",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.8,0.8,0.1*30",
	"$GPRMC,113744.568,V,4154.956,N,08002.496,W,89.3,0.10,220721,,E*44",
	"$GPGGA,113745.568,4154.956,N,08002.496,W,0,00,0.8,,M,,M,,*76",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.9,0.2,1.0*3B",
	"$GPRMC,113747.568,V,4154.958,N,08002.495,W,99.1,0.14,220721,,E*4D",
	"$GPGGA,113748.568,4154.958,N,08002.495,W,0,00,0.2,,M,,M,,*7C",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.7,0.1,0.2*35",
	"$GPRMC,113750.568,V,4154.960,N,08002.495,W,84.0,0.19,220721,,E*40",
	"$GPGGA,113751.568,4154.960,N,08002.495,W,0,00,0.1,,M,,M,,*7C",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.3,1.0,0.5*36",
	"$GPRMC,113753.568,V,4154.962,N,08002.495,W,24.0,0.13,220721,,E*41",
	"$GPGGA,113754.568,4154.962,N,08002.495,W,0,00,1.0,,M,,M,,*7B",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.7,0.8,0.9*37",
	"$GPRMC,113756.568,V,4154.963,N,08002.494,W,27.8,0.03,220721,,E*4E",
	"$GPGGA,113757.568,4154.963,N,08002.494,W,0,00,0.8,,M,,M,,*71",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.5,0.4,0.7*37"
}

local badGNSSSdata = {
	"$GPRMC,113702.568,V,4154.931,N,08002.497,W,95.5,0.02,220721,,E*48",
	"$GPGGA,113703.568,4154.931,N,08002.497,W,0,00,,,M,,M,,*54",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.1,0.8,0.6*33",
	"$GPRMC,113720.568,V,4154.942,N,08002.498,W,0.2,-0.02,220721,,E*5F",
	"$GPGGA,113721.568,4154.942,N,08002.498,W,0,00,0.1,,M,,M,,*82",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.2,0.5,0.7*35",
	"$GPRMC,113723.568,V,4154.944,N,08002.498,W,53.6,0.05,220721,,E*5A",
	"$GPGGA,113724.568,4154.944,N,08002.498,W,0,00,0.5,,M,,M,,*12",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,1.0,0.6,0.1*35",
	"$GPRMC,113726.568,V,4154.946,N,08002.498,W,76.6,0.04,220721,,E*9E",
	"$GPGGA,113727.568,4154.946,N,08002.498,W,0,00,0.6,,M,,M,,*94",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.2,0.3,0.7*32",
	"$GPRMC,113729.568,V,4154.948,N,08002.497,W,30.9,0.12,220721,,E*9C",
	"$GPGGA,113730.568,4154.948,N,08002.497,W,0,00,0.3,,M,,M,,*79",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.5,0.2,0.2*39",
	"$GPRMC,113705.568,V,4154.933,N,08002.497,W,86.0,-0.05,220721,,E*90",
	"$GPGGA,113706.568,4154.933,N,08002.497,W,0,00,0.8,,M,,M,,*42",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.2,0.0,0.4*43",
	"$GPRMC,113708.568,V,4154.935,N,08002.498,W,55.1,-0.10,220721,,E*44",
	"$GPGGA,113709.568,4154.935,N,08002.498,W,0,00,0.0,,M,,M,,*4A",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.7,0.2,0.8*4D",
	"$GPRMC,113711.568,V,4154.937,N,08002.498,W,95.0,-0.10,220721,,E*44",
	"$GPGGA,113712.568,4154.937,N,08002.498,W,0,00,0.2,,M,,M,,*44",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.7,0.6,0.3*4D",
	"$GPRMC,113714.568,V,4154.939,N,08002.498,W,28.0,-0.07,220721,,E*4D",
	"$GPGGA,113715.568,4154.939,N,08002.498,W,0,00,0.6,,M,,M,,*4D",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,1.0,1.0,0.5*24",
	"$GPRMC,113717.568,V,4154.940,N,08002.498,W,30.1,0.03,220721,,E*59",
	"$GPGGA,113718.568,4154.940,N,08002.498,W,0,00,1.0,,M,,M,,*4D",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.5,0.1,0.2*39",
	"$GPGGA,113736.568,4154.951,N,08002.496,W,0,00,0.8,,M,,M,,*79",
	"$GPGSA,A,3,09,02,08,05,11,15,,,,,,,0.2,0.6,0.1*39",
	"$GPRMC,113738.568,V,4154.953,N,08002.496,W,58.2,0.10,220721,,E*67",
	"$GPGGA,113739.568,4154.953,N,08002.496,W,0,00,0.6,,M,,M,,*79",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.6,0.9,0.7*35",
	"$GPRMC,113741.568,V,4154.955,N,08002.496,W,88.3,0.03,220721,,E*31",
	"$GPGGA,113742.568,4154.955,N,08002.496,W,0,00,0.9,,M,,M,,*33",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.8,0.8,0.1*34",
	"$GPRMC,113744.568,V,4154.956,N,08002.496,W,89.3,0.10,220721,,E*34",
	"$GPGGA,113745.568,4154.956,N,08002.496,W,0,00,0.8,,M,,M,,*75",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.9,0.2,1.0*4B",
	"$GPRMC,113747.568,V,4154.958,N,08002.495,W,99.1,0.14,220721,,E*5D",
	"$GPGGA,113748.568,4154.958,N,08002.495,W,0,00,0.2,,M,,M,,*5C",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.7,0.1,0.2*55",
	"$GPRMC,113750.568,V,4154.960,N,08002.495,W,84.0,0.19,220721,,E*50",
	"$GPGGA,113751.568,4154.960,N,08002.495,W,0,00,0.1,,M,,M,,*5C",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.3,1.0,0.5*35",
	"$GPRMC,113753.568,V,4154.962,N,08002.495,W,24.0,0.13,220721,,E*51",
	"$GPGGA,113754.568,4154.962,N,08002.495,W,0,00,1.0,,M,,M,,*5B",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.7,0.8,0.9*35",
	"$GPRMC,113756.568,V,4154.963,N,08002.494,W,27.8,0.03,220721,,E*5E",
	"$GPGGA,113757.568,4154.963,N,08002.494,W,0,00,0.8,,M,,M,,*51",
	"$GPGSA,A,2,09,02,08,05,11,15,,,,,,,0.5,0.4,0.7*57"
}

local GNSStr = "$GPRMC,143753.498,V,3854.930,N,07902.496,W,91.3,0.75,220721,,E*4B\r\n\
					   $GPGGA,143754.498,3854.930,N,07902.496,W,0,00,,,M,,M,,*53\r\n\
					   $GPGSA,A,2,13,09,13,09,18,16,,,,,,,0.1,0.0,0.2*3E\r\n\
					   $GPRMC,143756.498,V,3854.931,N,07902.494,W,92.7,0.76,220721,,E*49\r\n\
					   $GPGGA,143757.498,3854.931,N,07902.494,W,0,00,0.0,,M,,M,,*7D\r\n\
					   $GPGSA,A,2,13,09,13,09,18,16,,,,,,,0.4,0.4,0.5*38\r\n\
					   $GPRMC,143759.498,V,3854.932,N,07902.492,W,15.5,0.75,220721,,E*4D\r\n"

local badCRC = "$GPRMC,143753.498,V,3854.930,N,07902.496,W,91.3,0.75,220721,,E*6B\r\n\
					   $GPGGA,143754.498,3854.930,N,07902.496,W,0,00,,,M,,M,,*43\r\n\
					   $GPGSA,A,2,13,09,13,09,18,16,,,,,,,0.1,0.0,0.2*5E\r\n\
					   $GPRMC,143756.498,V,3854.931,N,07902.494,W,92.7,0.76,220721,,E*48\r\n\
					   $GPGGA,143757.498,3854.931,N,07902.494,W,0,00,0.0,,M,,M,,*4D\r\n\
					   $GPGSA,A,2,13,09,13,09,18,16,,,,,,,0.4,0.4,0.5*39\r\n\
					   $GPRMC,143759.498,V,3854.932,N,07902.492,W,15.5,0.75,220721,,E*3D\r\n"

local nmeaDataType = {"$GPGSA,", "$GPRMC,", "$GPGGA,"}
local badString = "oskdsajdij232391i*&^^&7^&^(*&*YDUDHJSBDNBNVyywfdywf"

function testBitXOR()
	lu.assertEquals(BitXOR(string.byte('q'), string.byte('r')), 3)
	lu.assertEquals(BitXOR(string.byte('a'), string.byte('b')), 3)
	lu.assertEquals(BitXOR(string.byte('1'), string.byte('5')), 4)
	lu.assertEquals(BitXOR(string.byte('0'), string.byte('0')), 0)
	lu.assertEquals(BitXOR(string.byte('9'), string.byte('1')), 8)
	lu.assertEquals(BitXOR(string.byte('f'), string.byte('w')), 17)
end

function testCRC()
	for i = 1, #goodGNSSSdata do
    	lu.assertEquals(checkCRC(goodGNSSSdata[i]), true)
    end
    for i = 1, #badGNSSSdata do
    	lu.assertEquals(checkCRC(badGNSSSdata[i]), false)
    end
end

function testCropData()
	for i = 1, #nmeaDataType do
		lu.assertEquals(getCropData("", nmeaDataType[i]), {true, "No data found"})
		lu.assertEquals(getCropData(badString, nmeaDataType[i]), {true, "No data found"})
		lu.assertEquals(getCropData(badCRC, nmeaDataType[i]), {true, "Checksum error"})
		lu.assertEquals(getCropData(GNSStr, nmeaDataType[i]), {false, "OK"})
	end
end

os.exit(lu.LuaUnit.run())