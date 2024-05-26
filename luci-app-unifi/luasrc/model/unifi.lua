local util  = require "luci.util"
local jsonc = require "luci.jsonc"

local unifi = {}

unifi.blocks = function()
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

unifi.home = function()
  local uci = require "luci.model.uci".cursor()
  local home_dirs = {}
  home_dirs["main_dir"] = uci:get_first("quickstart", "main", "main_dir", "/root")
  home_dirs["Configs"] = uci:get_first("quickstart", "main", "conf_dir", home_dirs["main_dir"].."/Configs")
  home_dirs["Caches"] = uci:get_first("quickstart", "main", "tmp_dir", home_dirs["main_dir"].."/Caches")
  return home_dirs
end

unifi.find_paths = function(blocks, home_dirs, path_name)
  local default_path = ''
  local configs = {}

  default_path = home_dirs[path_name] .. "/UnifiController"
  if #blocks == 0 then
    table.insert(configs, default_path)
  else
    for _, val in pairs(blocks) do 
      table.insert(configs, val .. "/" .. path_name .. "/UnifiController")
    end
    local without_conf_dir = "/root/" .. path_name .. "/UnifiController"
    if default_path == without_conf_dir then
      default_path = configs[1]
    end
  end

  return configs, default_path
end

return unifi
