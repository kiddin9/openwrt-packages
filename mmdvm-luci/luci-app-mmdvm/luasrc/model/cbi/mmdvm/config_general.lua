-- Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

local sys   = require "luci.sys"
local fs    = require "nixio.fs"
local json = require "luci.jsonc"

local m, s, o = ...

local mmdvm = require("luci.model.mmdvm")
local http  = require("luci.http")
-- local conffile = uci:get("mmdvm", "mmdvmhost", "conf") or "/etc/MMDVM.ini"

m = Map("mmdvm", "", translate("Here you can configure the basic aspects of your device like its callsign or the operating modes."))
m.on_after_commit = function(self)
	if self.changed then	-- changes ?
        changes = self.uci:changes("mmdvm")
        -- if MMDVM.ini changed?
        if mmdvm.uci2ini(changes) then
            sys.call("env -i /etc/init.d/mmdvmhost restart >/dev/null")
        end
	end
end

-- Initialize uci file using ini if needed, MUST called at the fist run.
mmdvm.ini2uci(m.uci)

--
-- General Properties
--
s = m:section(NamedSection, "General", "mmdvmhost", translate("General Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Value, "Callsign", translate("Callsign"))
o.optional    = false

o = s:option(Value, "Id", translate("ID"), translate("Your DmrId or DmrId + <abbr title=\"ex. 460713301\">2 digitals</abbr>"))
o.optional    = true
o.datatype    = "uinteger"

o = s:option(ListValue, "Duplex", translate("Duplex/Simplex"))
o:value("0", translate("Simplex"))
o:value("1", translate("Duplex"))

o = s:option(Value, "NetModeHang", translate("NetModeHang"))
o.datatype    = "uinteger"
o = s:option(Value, "RFModeHang", translate("RFModeHang"))
o.datatype    = "uinteger"

--
-- Info Properties
--
s = m:section(NamedSection, "Info", "mmdvmhost", translate("Infomation Settings"), translate("Those infomation will show up at brandmeister.network if you enable DMR mode"))
s.anonymous   = true

o = s:option(Value, "RXFrequency", translate("RXFrequency"), translate("Use the format <abbr title=\"the Unit is Hz\">434500000</abbr>, in Hz"))
o.optional    = true
o.datatype    = "uinteger"
o = s:option(Value, "TXFrequency", translate("TXFrequency"), translate("Use the same format as RXFrequency"))
o.optional    = true
o.datatype    = "uinteger"
o = s:option(Value, "Latitude", translate("Latitude"), translate("e.g. 22.10 N"))
o = s:option(Value, "Longitude", translate("Longitude"), translate("e.g. 114.3 E"))
o = s:option(Value, "Height", translate("Height"), translate("e.g. 110 Meters"))
o.optional    = true
o.datatype    = "uinteger"
o = s:option(Value, "Power", translate("TXPower"), translate("e.g. 1 Watt"))
o.optional    = true
o.datatype    = "uinteger"
o = s:option(Value, "Location", translate("Location"))
o = s:option(Value, "Description", translate("Description"))
o = s:option(Value, "URL", translate("URL"))

--
-- Modem Properties
--
s = m:section(NamedSection, "Modem", "mmdvmhost", translate("Modem Settings"))
s.anonymous   = true
o = s:option(ListValue, "Port", translate("Port"), translate("The port of Modem"))
o:value("NullModem", "NullModem")
if fs.access("/dev/ttyS1") then o:value("/dev/ttyS1") end
if fs.access("/dev/ttyUSB0") then o:value("/dev/ttyUSB0") end
if fs.access("/dev/ttyACM0") then o:value("/dev/ttyACM0") end
if fs.access("/dev/ttyAMA0") then o:value("/dev/ttyAMA0") end

o = s:option(Value, "RXOffset", translate("RXOffset"))
o = s:option(Value, "TXOffset", translate("TXOffset"))

o = s:option(Value, "RSSIMappingFile", translate("RSSIMappingFile"))

return m
