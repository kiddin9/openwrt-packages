local http = require "luci.http"
local nixio = require "nixio" 
local fs   = require "nixio.fs"
local ltn12 = require "luci.ltn12"

local iform = {} 
local const_log_end = "XU6J03M6"

function iform.log_end()
  return const_log_end
end

function iform.exec_to_log(command)
  local f = io.popen(command, "r")
  local log = command
  if f then
    local output = f:read('*all')
    f:close()
    log = log .. "\n" .. output .. const_log_end
  else
    log = log .. " Failed" .. const_log_end
  end
  return log
end

function iform.response_log(logpath)
  local logfd = io.open(logpath, "r")
  if logfd == nil then
    http.write("log not found" .. const_log_end)
    return
  end

  local curr = logfd:seek()
  local size = logfd:seek("end")
  if size > 8*1024 then
    logfd:seek("end", -8*1024)
  else
    logfd:seek("set", curr)
  end

  local write_log = function()
    local buffer = logfd:read(4096)
    if buffer and #buffer > 0 then
        return buffer
    else
        logfd:close()
        return nil
    end
  end

  http.prepare_content("text/plain;charset=utf-8")

  if logfd then
    ltn12.pump.all(write_log, http.write)
  end
end

function iform.fork_exec(command)
	local pid = nixio.fork()
	if pid > 0 then
		return
	elseif pid == 0 then
		-- change to root dir
		nixio.chdir("/")

		-- patch stdin, out, err to /dev/null
		local null = nixio.open("/dev/null", "w+")
		if null then
			nixio.dup(null, nixio.stderr)
			nixio.dup(null, nixio.stdout)
			nixio.dup(null, nixio.stdin)
			if null:fileno() > 2 then
				null:close()
			end
		end

		-- replace with target command
		nixio.exec("/bin/sh", "-c", command)
	end
end

return iform

