-------------------------------------------------------------------
-- Module is designed to work with the Yandex Locator API
-- (WiFi is required!)
-------------------------------------------------------------------
-- Copyright 2021-2022 Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0

local json    = require("luci.jsonc")
local sys     = require("luci.sys")
local iwinfo  = require("iwinfo")

locator = {}

local function configJSON(jsonData, iface, key)
	jsonData.common.api_key = key
	local inter = iwinfo.type(iface)
	local scanlist = iwinfo[inter].scanlist(iface)
	for _, v in pairs(scanlist) do
		v.bssid = string.gsub(v.bssid, ':', '')
		table.insert(jsonData.wifi_networks, {["mac"] = v.bssid, ["signal_strength"] = v.signal})
	end
end

local function request(curl, jsonData)
	curl = curl .. json.stringify(jsonData) .. '\''
	local res = sys.exec(curl)
	if res == "" then
		res = "{\"error\": {\"message\":\"No internet connection\"}}"
	end
	return json.parse(res)
end

-- Converter from degrees to NMEA data.
function locator.degreesToNmea(coord)
	local degrees = math.floor(coord)
	coord = math.abs(coord) - degrees
	local sign = coord < 0 and "-" or ""
	return sign .. string.format("%02i%02.5f", degrees, coord * 60.00)
end

-- Getting data coordinates via Yandex API
function locator.getLocation(iface_name, api_key)
	local curl = "curl -X POST 'http://api.lbs.yandex.net/geolocation' -d 'json="
	local jsonData = {
		wifi_networks = {},
		common = {
			version = "1.0",
			api_key = ""
		}
	}

	configJSON(jsonData, iface_name, api_key)
	local location = request(curl, jsonData)
	local err = {false, "OK"}
	local latitude  = ""
	local longitude = ""
	local altitude  = ""

	if location.error then
		err = {true, location.error.message}
	end

	if location.position then
		if tonumber(location.position.precision) >= 100000  then
			err = {true, "Bad precision"}
		else
			latitude  = string.format("%0.8f", location.position.latitude)
			longitude = string.format("%0.8f", location.position.longitude)
			if latitude == "" or longitude == "" then
				err = {true, "Bad data..."}
			end
		end
	end

	return err, latitude, longitude
end

return locator
