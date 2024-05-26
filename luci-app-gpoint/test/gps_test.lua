local gps = require("gps_lib")
--local kalman = require("kalman_lib")

function read_lat_lon()
	local file = io.open("/www/kalman_lua/matrix_c_test/testdata/gps_example_1", 'r')

	while file:read() do
		local lat, lon = file:read("*n", "*n")
		if lat and lon then
			return lat, lon
		end
	end

	file:close()
	print("read_lat_lon - OK")
end

function test_read_lat_long()
	local lat, lon = read_lat_lon()
	assert(math.abs(lat - 39.315828) < 0.000001)
	assert(math.abs(lon - -120.167838) < 0.000001)
	for i = 1, 131 do
		local lat, lon = read_lat_lon()
	end
	print("test_read_lat_long - OK")
end

function test_bearing_north()
	local kalman = gps.create_velocity2d(1.0)
	for i = 1, 100 do
		kalman = gps.update_velocity2d(kalman, i * 0.0001, 0.0, 1.0)
	end

	local bearing = gps.get_bearing(kalman)
	assert(math.abs(bearing - 0.0) < 0.01)

	local dlat, dlon = gps.get_velocity(kalman)
	assert(math.abs(dlat - 0.0001) < 0.00001)
	assert(math.abs(dlon) < 0.00001)
	print("test_bearing_north - OK")
end

function test_bearing_east()
	local kalman = gps.create_velocity2d(1.0)
	for i = 1, 100 do
		kalman = gps.update_velocity2d(kalman, 0.0, i * 0.0001, 1.0)
	end

	local bearing = gps.get_bearing(kalman)
	assert(math.abs(bearing - 90.0) < 0.01)
	--At this rate, it takes 10,000 timesteps to travel one longitude
    --unit, and thus 3,600,000 timesteps to travel the circumference of
    --the earth. Let's say one timestep is a second, so it takes
    --3,600,000 seconds, which is 60,000 minutes, which is 1,000
    --hours. Since the earth is about 25000 miles around, this means we
    --are traveling at about 25 miles per hour.
	local mph = gps.get_mph(kalman)
	assert(math.abs(mph - 25.0) < 2.0)
	print("test_bearing_east - OK")
end

function test_bearing_south()
	local kalman = gps.create_velocity2d(1.0)
	for i = 1, 100 do
		kalman = gps.update_velocity2d(kalman, i * -0.0001, 0.0, 1.0)
	end

	local bearing = gps.get_bearing(kalman)
	assert(math.abs(bearing - 180.0) < 0.01)
	print("test_bearing_south - OK")
end

function test_bearing_west()
	local kalman = gps.create_velocity2d(1.0)
	for i = 1, 100 do
		kalman = gps.update_velocity2d(kalman, 0.0, i * -0.0001, 1.0)
	end

	local bearing = gps.get_bearing(kalman)
	assert(math.abs(bearing - 270.0) < 0.01)
	print("test_bearing_west - OK")
end

function test_calculate_mph()
	local mph = gps.calculate_mph(39.315842, -120.167107, -0.000031, 0.000003);
	assert(math.abs(mph - 7.74) < 0.01);
	print("test_calculate_mph - OK")
end

-- test start
test_read_lat_long()
test_bearing_north()
test_bearing_east()
test_bearing_south()
test_bearing_west()
test_calculate_mph()