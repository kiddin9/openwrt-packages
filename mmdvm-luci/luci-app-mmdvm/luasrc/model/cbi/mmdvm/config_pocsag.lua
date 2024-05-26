-- Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

local sys   = require "luci.sys"
local fs    = require "nixio.fs"
local json = require "luci.jsonc"

local m, s, o = ...

local mmdvm = require("luci.model.mmdvm")
local http  = require("luci.http")

m = Map("mmdvm")
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
-- POCSAG Properties
--
s = m:section(NamedSection, "POCSAG", "mmdvmhost", translate("POCSAG Settings"))
s.anonymous   = true

o = s:option(Flag, "Enable", translate("Enable POCSAG Mode"))
o.rmempty = false
function o.cfgvalue(self)
    return sys.init.enabled("dapnetgateway")
        and self.enabled or self.disabled
end
function o.write(self, section, value)
    if value == self.enabled then
        sys.init.enable("dapnetgateway")
        sys.call("env -i /etc/init.d/dapnetgateway restart >/dev/null")
    else
        sys.init.disable("dapnetgateway")
        sys.call("env -i /etc/init.d/dapnetgateway stop >/dev/null")
    end
    AbstractValue.write(self, section, value)
    self.map.uci:set("mmdvm", "POCSAG_Network", "Enable", value)
end

o = s:option(Value, "Frequency", translate("Frequency"), translate("Use the format <abbr title=\"the Unit is Hz\">434500000</abbr>, in Hz"))
o.optional    = true
o.datatype    = "uinteger"


s = m:section(NamedSection, "DAPNET_General", "dapnetgateway")
s.anonymous   = true

o = s:option(Value, "Callsign", translate("Callsign"))
o.optional    = false

s = m:section(NamedSection, "DAPNET_DAPNET", "dapnetgateway")
s.anonymous   = true

o = s:option(ListValue, "Address", "DAPNET " .. translate("Server"))
local dapnetservers = {"dapnet.afu.rwth-aachen.de", "node1.dapnet-italia.it"}
for _, r in ipairs(dapnetservers) do
    o:value(r, r)
end

o = s:option(Value, "AuthKey", translate("AuthKey"))
o.optional    = false

return m
