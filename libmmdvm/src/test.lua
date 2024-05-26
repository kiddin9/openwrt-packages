#!/usr/bin/env lua

local mmdvm = require("mmdvm")

mmdvm.init("/Volumes/Dev/radioid/export")
rtl = mmdvm.get_user_by_callsign("BD7MQB")
assert(type(rtl) == 'table', 'return value must be table')
assert(rtl.name == 'Michael Changzhi Cai', 'value unexpected')
-- assert(rtl.city == 'ShenzhenGuangdong', 'value unexpected')
assert(rtl.country == 'China', 'value unexpected')

print(rtl.name)
-- print(rtl.city)
print(rtl.country)

rtl = mmdvm.get_dmrid_by_callsign("BD7MQB")
assert(type(rtl) == 'string', 'return value must be string')
assert(rtl == "Michael Changzhi Cai\tCN", 'value unexpected')

print(rtl)

rtl = mmdvm.get_user_by_callsign("BD9AAA")
assert(rtl == nil, 'value should be nil')
rtl = mmdvm.get_dmrid_by_callsign("BD9AAA")
assert(type(rtl) == 'string', 'return value must be string')
assert(rtl == "", 'value should be empty')
