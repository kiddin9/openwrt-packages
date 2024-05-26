local kalman = require("kalman_lib")
local matrix = require("matrix_lib")

gps_lib = {}

local PI = 3.14159265
local EARTH_RADIUS_IN_MILES = 3963.1676

function gps_lib.set_seconds_per_timestep(kalman_filter, seconds_per_timestep)
	local unit_scaler = 0.001
	kalman_filter.state_transition[1][3] = unit_scaler * seconds_per_timestep
	kalman_filter.state_transition[2][4] = unit_scaler * seconds_per_timestep
	return kalman_filter
end

function gps_lib.create_velocity2d(noise)
	local kalman_filter = kalman.create(4, 2)
	local v2p = 0.001

	kalman_filter.state_transition = matrix.set_identity(kalman_filter.state_transition)
	kalman_filter = gps_lib.set_seconds_per_timestep(kalman_filter, 1.0)
	kalman_filter.observation_model = matrix.set(kalman_filter.observation_model, 
												 1.0, 0.0, 0.0, 0.0,
												 0.0, 1.0, 0.0, 0.0)

	local pos = 0.000001
	kalman_filter.process_noise_covariance = matrix.set(kalman_filter.process_noise_covariance, 
														pos, 0.0, 0.0, 0.0,
														0.0, pos, 0.0, 0.0,
														0.0, 0.0, 1.0, 0.0,
														0.0, 0.0, 0.0, 1.0)

	kalman_filter.observation_noise_covariance = matrix.set(kalman_filter.observation_noise_covariance,
															pos * noise, 0.0,
															0.0, pos * noise)

	kalman_filter.state_estimate = matrix.set(kalman_filter.state_estimate, 0.0, 0.0, 0.0, 0.0)
	kalman_filter.estimate_covariance = matrix.set_identity(kalman_filter.estimate_covariance)
	local trillion = 1000.0 * 1000.0 * 1000.0 * 1000.0
	kalman_filter.estimate_covariance = matrix.scale(kalman_filter.estimate_covariance, trillion)
	return kalman_filter
end

function gps_lib.update_velocity2d(kalman_filter, lat, lon, seconds_since_last_timestep)
	kalman_filter = gps_lib.set_seconds_per_timestep(kalman_filter, seconds_since_last_timestep)
	kalman_filter.observation = matrix.set(kalman_filter.observation, lat * 1000.0, lon * 1000.0)
	kalman_filter = kalman.update(kalman_filter)
	return kalman_filter
end

function gps_lib.get_lat_lon(kalman_filter)
	return string.format("%0.6f", kalman_filter.state_estimate[1][1] / 1000.0), 
		   string.format("%0.6f", kalman_filter.state_estimate[2][1] / 1000.0)
end

function gps_lib.get_velocity(kalman_filter)
	return  kalman_filter.state_estimate[3][1] / (1000.0 * 1000.0), 
			kalman_filter.state_estimate[4][1] / (1000.0 * 1000.0)
end

function gps_lib.get_bearing(kalman_filter)
	local lat, lon = gps_lib.get_lat_lon(kalman_filter)
	local delta_lat, delta_lon = gps_lib.get_velocity(kalman_filter)

	local to_radians = PI / 180.0
	lat = lat * to_radians
	lon = lon * to_radians
	delta_lat = delta_lat * to_radians
	delta_lon = delta_lon * to_radians

	local lat1 = lat - delta_lat
	local y = math.sin(delta_lon) * math.cos(lat)
	local x = math.cos(lat1) * math.sin(lat) - math.sin(lat1) * math.cos(lat) * math.cos(delta_lon)
	local bearing = math.atan2(y, x)

	bearing = bearing / to_radians
	while bearing >= 360 do
		bearing = bearing - 360
	end
	while bearing < 0 do
		bearing = bearing + 360
	end
	return bearing
end

function gps_lib.calculate_mph(lat, lon, delta_lat, delta_lon)
	local to_radians = PI / 180
	lat = lat * to_radians
	lon = lon * to_radians
	delta_lat = delta_lat * to_radians
	delta_lon = delta_lon * to_radians

	local lat1 = lat - delta_lat
	local sin_half_dlat = math.sin(delta_lat / 2)
	local sin_half_dlon = math.sin(delta_lon / 2)

	local a = sin_half_dlat * sin_half_dlat + math.cos(lat1) * math.cos(lat) * sin_half_dlon * sin_half_dlon
	local radians_per_second = 2 * math.atan2(1000 * math.sqrt(a), 1000 * math.sqrt(1.0 - a))

	local miles_per_second = radians_per_second * EARTH_RADIUS_IN_MILES
	local miles_per_hour = miles_per_second * 60 * 60
	return miles_per_hour
end

function gps_lib.get_mph(kalman_filter)
	local lat, lon = gps_lib.get_lat_lon(kalman_filter)
	local delta_lat, delta_lon = gps_lib.get_velocity(kalman_filter)
	return gps_lib.calculate_mph(lat, lon, delta_lat, delta_lon)
end

return gps_lib