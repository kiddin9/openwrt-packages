-- Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2

local sys = require "luci.sys"
local fs    = require("nixio.fs")
local util  = require("luci.util")
local uci   = require("luci.model.uci").cursor()
local input = uci:get("mmdvm", "dapnetgateway", "conf") or "/etc/DAPNETGateway.ini"

if not fs.access(input) then
	m = SimpleForm("error", nil, translate("Input file not found, please check your configuration."))
	m.reset = false
	m.submit = false
	return m
end

if fs.stat(input).size >= 102400 then
	m = SimpleForm("error", nil,
		translate("The file size is too large for online editing in LuCI (&ge; 100 KB). ")
		.. translate("Please edit this file directly in a terminal session."))
	m.reset = false
	m.submit = false
	return m
end

m = SimpleForm("input", nil)
m:append(Template("mmdvm/config_css"))
m.submit = translate("Save & Reload Service")
m.reset = false

s = m:section(SimpleSection, nil,
	translatef("This form allows you to modify the .ini file of the DAPNETGateway (%s). ", input))

f = s:option(TextValue, "data")
f.datatype = "string"
f.rows = 20
f.rmempty = true

function f.cfgvalue()
	return fs.readfile(input) or ""
end

function f.write(self, section, data)
	ret = fs.writefile(input, "\n" .. util.trim(data:gsub("\r\n", "\n")) .. "\n")
	sys.call("/etc/init.d/dapnetgateway restart >/dev/null")
	sys.call("/etc/init.d/mmdvmhost restart >/dev/null")
	
	return ret
end

function f.remove(self, section, value)
	return fs.writefile(input, "")
end

function s.handle(self, state, data)
	return true
end

return m
