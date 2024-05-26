common_path = '/usr/share/gpoint/lib/?.lua;'
package.path = common_path .. package.path


function printData(data, key)
	for i, j in pairs(data) do
		if i == key then
			print("----->",i)
			for k, v in pairs(j) do
				print(k, v)
				print("*********************")
			end
		end
	end
	print("----------------------------------------------")
end

function printError(data)
	for i, j in pairs(data) do
		print(i)
		for k, v in pairs(j) do
			if k == "app" then
				for m, n in pairs(v) do
					print(m, n)
				end
			end
		end
	end
end

local nmea = require("nmea")
local port = "/dev/ttyUSB1"

-- test get NMEA data (GGA)
--local GGA = nmea.getData("GGA", port)
--printData(GGA, "gga")

-- test get NMEA data (GNS)
--local GNS = nmea.getData("GNS", port)
--printData(GNS, "gns")

-- test get RMC data (RMC)
--local RMC = nmea.getData("RMC", port)
--printData(RMC, "rmc")

-- test get NMEA data (VTG)
--local VTG = nmea.getData("VTG", port)
--printData(VTG, "vtg")

-- test get NMEA data (GSA)
--local GSA = nmea.getData("GSA", port)
--printData(GSA, "gsa")

-- test get NMEA data (BAD STRING)
--local AAA = nmea.getData("AAA", port)
--printError(AAA)