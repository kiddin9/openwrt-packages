common_path = '/usr/share/gpoint/lib/?.lua;'
package.path = common_path .. package.path

serial = require("serial")

function serial_read(port)
	local err, data = serial.read(port)
	assert(err, data)
	print("Error data: OK")
	assert(data)
	print("Data from serial: OK")
end
local port = "/dev/ttyUSB1"
serial_read(port)

print("OK")