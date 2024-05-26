local util  = require "luci.util"
local jsonc = require "luci.jsonc"
local nixio = require "nixio"

local wxedge = {}

wxedge.blocks = function()
  local f = io.popen("lsblk -s -f -b -o NAME,FSSIZE,MOUNTPOINT --json", "r")
  local vals = {}
  if f then
    local ret = f:read("*all")
    f:close()
    local obj = jsonc.parse(ret)
    for _, val in pairs(obj["blockdevices"]) do
      local fsize = val["fssize"]
      if fsize ~= nil and string.len(fsize) > 10 and val["mountpoint"] then
        -- fsize > 1G
        vals[#vals+1] = val["mountpoint"]
      end
    end
  end
  return vals
end

wxedge.default_image = function()
  if string.find(nixio.uname().machine, "x86_64") then
    return "onething1/wxedge"
  else
    return "onething1/wxedge:2.4.3"
  end
end

return wxedge

