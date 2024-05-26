-- Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

local sys   = require "luci.sys"
local fs    = require "nixio.fs"
local json = require "luci.jsonc"

local m, s, o = ...

local mmdvm = require("luci.model.mmdvm")
local http  = require("luci.http")
-- local conffile = uci:get("mmdvm", "mmdvmhost", "conf") or "/etc/MMDVM.ini"

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
-- DMR Properties
--
s = m:section(NamedSection, "DMR", "mmdvmhost", translate("DMR Settings"))
s.anonymous   = true

o = s:option(Flag, "Enable", translate("Enable DMR Mode"))
o.rmempty = false
function o.write(self, section, value)
    AbstractValue.write(self, section, value)
    self.map.uci:set("mmdvm", "DMR_Network", "Enable", value)
end

o = s:option(ListValue, "ColorCode", translate("ColorCode"), translate("Personal hotspots typically use color code 1"))
for i=1,12,1 do
    o:value(i, i)
end
o = s:option(Flag, "SelfOnly", translate("SelfOnly"), translate("Only the callsign you entered above shall pass in DMR mode"))
o.rmempty = false

o = s:option(Flag, "DumpTAData", translate("DumpTAData"), translate("Which enables \"Talker Alias\" information to be received by radios that support this feature"))
o.rmempty = false

--
-- DMR Network
--
s = m:section(NamedSection, "DMR_Network", "mmdvmhost")
s.anonymous   = true
o = s:option(ListValue, "Address", translate("DMR Server"))
for _, r in ipairs(mmdvm.get_bm_list()) do
    o:value(r[3], "BM" .. r[1] .. " " .. r[2])
end

o = s:option(Value, "Password", translate("Password"))
o.optional    = true

--
-- YSF Properties
--
s = m:section(NamedSection, "System_Fusion", "mmdvmhost", translate("YSF Settings"))
s.anonymous   = true

o = s:option(Flag, "Enable", translate("Enable YSF Mode"))
o.rmempty = false
function o.cfgvalue(self)
    return sys.init.enabled("ysfgateway")
        and self.enabled or self.disabled
end
function o.write(self, section, value)
    if value == self.enabled then
        sys.init.enable("ysfgateway")
        sys.init.enable("ysfparrot")
        sys.init.restart("ysfgateway")
        sys.init.restart("ysfparrot")
    else
        sys.init.stop("ysfgateway")
        sys.init.stop("ysfparrot")
        sys.init.disable("ysfgateway")
        sys.init.disable("ysfparrot")
    end
    AbstractValue.write(self, section, value)
    self.map.uci:set("mmdvm", "System_Fusion_Network", "Enable", value)
    -- sync ysf callsign with mmdvmhost's
    self.map.uci:set("mmdvm", "YSFG_General", "ysfgateway")
    self.map.uci:set("mmdvm", "YSFG_General", "Callsign", self.map.uci:get("mmdvm", "General", "Callsign"))
end

o = s:option(Flag, "SelfOnly", translate("SelfOnly"), translate("Only the callsign you entered above shall pass in YSF mode"))
o.rmempty = false

s = m:section(NamedSection, "YSFG_Network", "ysfgateway")
s.anonymous   = true
o = s:option(ListValue, "Startup", translate("Startup Reflector"))
for _, r in ipairs(mmdvm.get_ysf_list()) do
    o:value(r[2], r[1] .. " - " .. r[2])
end

o = s:option(Value, "InactivityTimeout", translate("InactivityTimeout"), translate("Minutes to disconect when idle"))
o.optional    = false
o.datatype    = "uinteger"
o = s:option(Flag, "Revert", translate("Revert to Startup"), translate("Revert to Startup reflector when InactivityTimeout"))
o.rmempty = false

--
-- P25 Properties
--
s = m:section(NamedSection, "P25", "mmdvmhost", translate("P25 Settings"))
s.anonymous   = true

o = s:option(Flag, "Enable", translate("Enable P25 Mode"))
o.rmempty = false
function o.cfgvalue(self)
    return sys.init.enabled("p25gateway")
        and self.enabled or self.disabled
end
function o.write(self, section, value)
    if value == self.enabled then
        sys.init.enable("p25gateway")
        sys.init.enable("p25parrot")
        sys.init.restart("p25gateway")
        sys.init.restart("p25parrot")
    else
        sys.init.stop("p25gateway")
        sys.init.stop("p25parrot")
        sys.init.disable("p25gateway")
        sys.init.disable("p25parrot")
    end
    AbstractValue.write(self, section, value)
    self.map.uci:set("mmdvm", "P25_Network", "Enable", value)
    -- sync callsign with mmdvmhost's
    self.map.uci:set("mmdvm", "P25G_General", "p25gateway")
    self.map.uci:set("mmdvm", "P25G_General", "Callsign", self.map.uci:get("mmdvm", "General", "Callsign"))
end

o = s:option(Value, "NAC", translate("NAC"), translate("Network Access Control"))
o.optional    = false
o.datatype    = "uinteger"

o = s:option(Flag, "SelfOnly", translate("SelfOnly"), translate("Only the callsign you entered above shall pass in P25 mode"))
o.rmempty = false

o = s:option(Flag, "OverrideUIDCheck", translate("OverrideUIDCheck"), translate("Only vaild IDs shall pass on RF transmition by unchecked this"))
o.rmempty = false

s = m:section(NamedSection, "P25G_Network", "p25gateway")
s.anonymous   = true
o = s:option(ListValue, "Startup", translate("Startup Reflector"))
for _, r in ipairs(mmdvm.get_p25_list()) do
    o:value(r[1], r[1] .. " - " .. r[2])
end

o = s:option(Value, "InactivityTimeout", translate("InactivityTimeout"), translate("Minutes to disconect when idle"))
o.optional    = false
o.datatype    = "uinteger"
o = s:option(Flag, "Revert", translate("Revert to Startup"), translate("Revert to Startup reflector when InactivityTimeout"))
o.rmempty = false

--
-- NXDN Properties
--
s = m:section(NamedSection, "NXDN", "mmdvmhost", translate("NXDN Settings"))
s.anonymous   = true

o = s:option(Flag, "Enable", translate("Enable NXDN Mode"))
o.rmempty = false
function o.cfgvalue(self)
    return sys.init.enabled("nxdngateway")
        and self.enabled or self.disabled
end
function o.write(self, section, value)
    if value == self.enabled then
        sys.init.enable("nxdngateway")
        sys.init.enable("nxdnparrot")
        sys.init.restart("nxdngateway")
        sys.init.restart("nxdnparrot")
    else
        sys.init.stop("nxdngateway")
        sys.init.stop("nxdnparrot")
        sys.init.disable("nxdngateway")
        sys.init.disable("nxdnparrot")
    end
    AbstractValue.write(self, section, value)
    self.map.uci:set("mmdvm", "NXDN_Network", "Enable", value)
    -- sync callsign with mmdvmhost's
    self.map.uci:set("mmdvm", "NXDNG_General", "nxdngateway")
    self.map.uci:set("mmdvm", "NXDNG_General", "Callsign", self.map.uci:get("mmdvm", "General", "Callsign"))
end

s = m:section(NamedSection, "NXDNG_Network", "nxdngateway")
s.anonymous   = true
o = s:option(ListValue, "Startup", translate("Startup Reflector"))
for _, r in ipairs(mmdvm.get_nxdn_list()) do
    o:value(r[1], r[1] .. " - " .. r[2])
end

o = s:option(Value, "InactivityTimeout", translate("InactivityTimeout"), translate("Minutes to disconect when idle"))
o.optional    = false
o.datatype    = "uinteger"
o = s:option(Flag, "Revert", translate("Revert to Startup"), translate("Revert to Startup reflector when InactivityTimeout"))
o.rmempty = false


--
-- D-Star Properties
--
s = m:section(NamedSection, "DStar", "mmdvmhost", translate("D-Star Settings"))
s.anonymous   = true

o = s:option(Flag, "Enable", translate("Enable D-Star Mode"))
o.rmempty = false
function o.cfgvalue(self)
    return sys.init.enabled("ircddbgateway")
        and self.enabled or self.disabled
end
function o.write(self, section, value)
    if value == self.enabled then
        sys.init.enable("ircddbgateway")
        sys.init.enable("timeserver")
        sys.init.restart("ircddbgateway")
        sys.init.restart("timeserver")
    else
        sys.init.stop("ircddbgateway")
        sys.init.stop("timeserver")
        sys.init.disable("ircddbgateway")
        sys.init.disable("timeserver")
    end
    AbstractValue.write(self, section, value)
    self.map.uci:set("mmdvm", "DStar_Network", "Enable", value)

    -- sync callsign with mmdvmhost's
    self.map.uci:set("mmdvm", "ircddbgateway", "dstar")
    self.map.uci:set("mmdvm", "ircddbgateway", "gatewayCallsign", self.map.uci:get("mmdvm", "General", "Callsign"))
    self.map.uci:set("mmdvm", "ircddbgateway", "repeaterCall1", self.map.uci:get("mmdvm", "General", "Callsign"))
    self.map.uci:set("mmdvm", "ircddbgateway", "ircddbUsername", self.map.uci:get("mmdvm", "General", "Callsign"))
    self.map.uci:set("mmdvm", "ircddbgateway", "dplusLogin", self.map.uci:get("mmdvm", "General", "Callsign"))
end

local callsign = m.uci:get("mmdvm", "General", "Callsign")
s = m:section(NamedSection, "DStar", "mmdvmhost")
s.anonymous   = true
o = s:option(ListValue, "Module", translate("RPT1 Callsign"))
for i=65, 90 do
    local module = ("%c"):format(i)
    o:value(module, callsign .. " " .. module)
end
o = s:option(DummyValue, "", translate("RPT2 Callsign"))
function o.cfgvalue(self)
    return callsign .. " G"
end

local reflector1 = m.uci:get("mmdvm", "ircddbgateway", "reflector1")
s = m:section(NamedSection, "ircddbgateway", "dstar")
s.anonymous   = true
o = s:option(Value, "reflector1", translate("Startup Reflector"))


-- TODO: change reflector1 to drop down list style
-- 
-- local reflector1 = m.uci:get("mmdvm", "ircddbgateway", "reflector1")
-- s = m:section(NamedSection, "ircddbgateway", "dstar")
-- s.anonymous   = true
-- o = s:option(ListValue, "reflector1", translate("Startup Reflector"))
-- for i=1, 999 do
--     local ref = ("XRF%03d"):format(i)
--     o:value(ref, ref)
-- end
-- function o.cfgvalue(self)
--     return reflector1:sub(1, reflector1:find(" ")-1)
-- end


-- function o.cfgvalue(self)
--     return reflector1:sub(reflector1:find(" ")+1, -1)
-- end

return m
