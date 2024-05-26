-------------------------------------------------------------------
-- Wrapper for working with a modem via serial port
-------------------------------------------------------------------
-- Copyright 2021-2022 Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0

local rs232 = require("luars232")

local serial = {}

local function configSerial(port)
	assert(port:set_baud_rate(rs232.RS232_BAUD_115200)  == rs232.RS232_ERR_NOERROR)
	assert(port:set_parity(rs232.RS232_PARITY_NONE)     == rs232.RS232_ERR_NOERROR)
	assert(port:set_data_bits(rs232.RS232_DATA_8)       == rs232.RS232_ERR_NOERROR)
	assert(port:set_stop_bits(rs232.RS232_STOP_1)       == rs232.RS232_ERR_NOERROR)
	assert(port:set_flow_control(rs232.RS232_FLOW_OFF)	== rs232.RS232_ERR_NOERROR)
end

-- write data from modem (AT PORT)
function serial.write(serial_port, command)
	local err, port = rs232.open(serial_port)
	if err ~= rs232.RS232_ERR_NOERROR then
		err = {true, "Error opening AT port"}
		assert(port:close() == rs232.RS232_ERR_NOERROR)
		return err
	end
	configSerial(port)

	local err, len_written = port:write(command  .. "\r\n")
	if err ~= rs232.RS232_ERR_NOERROR then
		err = {true, "Error writing AT port"}
		assert(port:close() == rs232.RS232_ERR_NOERROR)
		return err
	end

	err = {false, "OK"}
	assert(port:close() == rs232.RS232_ERR_NOERROR)
	return err
end

-- read data from modem (GNSS PORT)
function serial.read(serial_port)
	local err, port = rs232.open(serial_port)
	if err ~= rs232.RS232_ERR_NOERROR then
		err = {true, "Error opening GNSS port"}
		assert(port:close() == rs232.RS232_ERR_NOERROR)
		return err, ''
	end
	configSerial(port)

	local READ_LEN = 1024  -- Read byte form GNSS port
	local TIMEOUT  = 1000  -- Timeout reading in miliseconds

	local serialData, err, read_data = {}, "", ""
	while READ_LEN > 0 do
		err, read_data = port:read(1, TIMEOUT)
		if err ~= rs232.RS232_ERR_NOERROR then
			err = {true, "Error reading GNSS port. Updating data or searching for satellites..."}
			assert(port:close() == rs232.RS232_ERR_NOERROR)
			return err, ""
		end
		if read_data ~= nil then
			table.insert(serialData, read_data)
			READ_LEN = READ_LEN - 1
		end
	end
	assert(port:close() == rs232.RS232_ERR_NOERROR)

	err = {false, "OK"}
	return err, table.concat(serialData)
end

return serial
