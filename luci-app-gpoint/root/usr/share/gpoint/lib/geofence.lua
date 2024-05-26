-- GeoFence
-- (c) 2023 modified by Vladislav Kadulin (spanky@yandex.ru)

local sys  = require("luci.sys")
local geohash = require("geohash")

geofence = {}

function geofence.encode(latitude, longitude, precision)
	return geohash.encode(latitude, longitude, precision)
end

function geofence.equal(GnssData, precision, area_hash)
	return geohash.encode(GnssData.gp.latitude, GnssData.gp.longitude, precision) == area_hash
end

function geofence.script(newGeoFence, oldGeoFence, option)
	if newGeoFence and not oldGeoFence then
		if option == "Leaving" or option == "All" then
			sys.exec(geofenceConfig.path)
		end
	elseif not newGeoFence and oldGeoFence then
		if option == "Coming" or option == "All" then
			sys.exec(geofenceConfig.path)
		end
	end
end

return geofence