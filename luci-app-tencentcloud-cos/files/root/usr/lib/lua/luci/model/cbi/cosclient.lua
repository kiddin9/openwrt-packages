--[[
LuCI - Lua Configuration Interface

Copyright 2010 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

require("luci.sys")

m = Map("cosclient", translate("COSFS Client"), translate("Configure COSFS Client."))

s = m:section(TypedSection, "cosclient", "")
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enable", translate("EnableCos"))
secretid = s:option(Value, "secretid", translate("secretId"))
secretkey = s:option(Value, "secretkey", translate("secretKey"))
bucket = s:option(Value, "bucket", translate("BucketName"))
region = s:option(Value, "region", translate("Region"))
folder = s:option(Value, "folder", translate("FolderName"))

local apply=luci.http.formvalue("cbi.apply")
if apply then
local key, val
local Enable
local Secretid
local Secretkey
local Bucket
local Region
for key, val in pairs(luci.http.formvalue()) do
       if(string.find(key,"enable"))
       then
          Enable=val
       elseif(string.find(key,"secretid"))
       then
          Secretid=val
       elseif(string.find(key,"secretkey"))
       then
          Secretkey=val
      elseif(string.find(key,"bucket"))
      then
          Bucket=val
      elseif(string.find(key,"region"))
      then
          Region=val
      end
end
 luci.sys.call("/etc/uploadData 1 "..Enable.." "..Secretid.." "..Secretkey.." "..Bucket.." "..Region.." > /dev/null")
end

return m
