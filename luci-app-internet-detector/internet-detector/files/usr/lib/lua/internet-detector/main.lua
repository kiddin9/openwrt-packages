
local dirent = require("posix.dirent")
local fcntl  = require("posix.fcntl")
local signal = require("posix.signal")
local socket = require("posix.sys.socket")
local stat   = require("posix.sys.stat")
local syslog = require("posix.syslog")
local time   = require("posix.time")
local unistd = require("posix.unistd")
local uci    = require("uci")

-- Default settings

local InternetDetector = {
	mode           = 0,		-- 0: disabled, 1: Service, 2: UI detector
	enableLogger   = true,
	hostname       = "OpenWrt",
	appName        = "internet-detector",
	commonDir      = "/tmp/run",
	libDir         = "/usr/lib/lua",
	pingCmd        = "/bin/ping",
	pingParams     = "-c 1",
	uiRunTime      = 30,
	noModules      = false,
	uiAvailModules = { mod_public_ip = true },
	debug          = false,
	serviceConfig  = {
		hosts = {
			[1] = "8.8.8.8",
			[2] = "1.1.1.1",
		},
		check_type          = 0,	-- 0: TCP, 1: ICMP
		tcp_port            = 53,
		icmp_packet_size    = 56,
		interval_up         = 30,
		interval_down       = 5,
		connection_attempts = 2,
		connection_timeout  = 2,
		iface               = nil,
		instance            = nil,
	},
	modules       = {},
	parsedHosts   = {},
	uiCounter     = 0,
}
InternetDetector.configDir  = string.format("/etc/%s", InternetDetector.appName)
InternetDetector.modulesDir = string.format(
	"%s/%s", InternetDetector.libDir, InternetDetector.appName)

-- Loading settings from UCI

local uciCursor = uci.cursor()
local mode, err = uciCursor:get(InternetDetector.appName, "config", "mode")
if mode ~= nil then
	InternetDetector.mode = tonumber(mode)
elseif err then
	io.stderr:write(string.format("Error: %s\n", err))
end
local enableLogger, err = uciCursor:get(InternetDetector.appName, "config", "enable_logger")
if enableLogger ~= nil then
	InternetDetector.enableLogger = (tonumber(enableLogger) ~= 0)
elseif err then
	io.stderr:write(string.format("Error: %s\n", err))
end
local hostname, err = uciCursor:get("system", "@[0]", "hostname")
if hostname ~= nil then
	InternetDetector.hostname = hostname
elseif err then
	io.stderr:write(string.format("Error: %s\n", err))
end

local _RUNNING

function InternetDetector:prequire(package)
	local retVal, pkg = pcall(require, package)
	return retVal and pkg
end

function InternetDetector:loadUCIConfig(sType, instance)
	local success
	local num = 0
	uciCursor:foreach(
		self.appName,
		sType,
		function(s)
			if s[".name"] == instance then
				for k, v in pairs(s) do
					if type(v) == "string" and v:match("^[%d]+$") then
						v = tonumber(v)
					end
					self.serviceConfig[k] = v
				end
				success = true
				self.serviceConfig.instanceNum = num
			end
			num = num + 1
		end
	)
	self.serviceConfig.instance = instance
	self.pidFile    = string.format(
		"%s/%s.%s.pid", self.commonDir, self.appName, instance)
	self.statusFile = string.format(
		"%s/%s.%s.status", self.commonDir, self.appName, instance)
	return success
end

function InternetDetector:writeValueToFile(filePath, str)
	local retValue = false
	local fh       = io.open(filePath, "w")
	if fh then
		fh:setvbuf("no")
		fh:write(string.format("%s\n", str))
		fh:close()
		retValue = true
	end
	return retValue
end

function InternetDetector:readValueFromFile(filePath)
	local retValue
	local fh = io.open(filePath, "r")
	if fh then
		retValue = fh:read("*l")
		fh:close()
	end
	return retValue
end

function InternetDetector:statusJson(inet, instance, t)
	local lines = { [1] = string.format(
		'{"instance":"%s","num":"%d","inet":%d',
		instance,
		self.serviceConfig.instanceNum,
		inet)}
	if t then
		for k, v in pairs(t) do
			lines[#lines + 1] = string.format('"%s":"%s"', k, v)
		end
	end
	return table.concat(lines, ",") .. "}"
end

function InternetDetector:writeLogMessage(level, msg)
	if self.enableLogger then
		local levels = {
			emerg   = syslog.LOG_EMERG,
			alert   = syslog.LOG_ALERT,
			crit    = syslog.LOG_CRIT,
			err     = syslog.LOG_ERR,
			warning = syslog.LOG_WARNING,
			notice  = syslog.LOG_NOTICE,
			info    = syslog.LOG_INFO,
			debug   = syslog.LOG_DEBUG,
		}
		syslog.syslog(levels[level] or syslog.LOG_INFO, string.format(
			"%s: %s", self.serviceConfig.instance or "", msg))
	end
end

function InternetDetector:loadModules()
	self.modules = {}
	local ok, modulesDir = pcall(dirent.files, self.modulesDir)
	if ok then
		for item in modulesDir do
			if item:match("^mod_") then
				local modName = item:gsub("%.lua$", "")
				if self.noModules and not self.uiAvailModules[modName] then
				else
					local modConfig = {}
					for k, v in pairs(self.serviceConfig) do
						if k:match("^" .. modName) then
							modConfig[k:gsub("^" .. modName .. "_", "")] = v
						end
					end
					if modConfig.enabled == 1 then
						local m
						if self.debug then
							m = require(string.format("%s.%s", self.appName, modName))
						else
							m = self:prequire(string.format("%s.%s", self.appName, modName))
						end
						if m then
							m.config     = self
							m.syslog     = function(level, msg) self:writeLogMessage(level, msg) end
							m.writeValue = function(filePath, str) return self:writeValueToFile(filePath, str) end
							m.readValue  = function(filePath) return self:readValueFromFile(filePath) end
							m:init(modConfig)
							self.modules[#self.modules + 1] = m
						end
					end
				end
			end
		end
		table.sort(self.modules, function(a, b) return a.runPrio < b.runPrio end)
	end
end

function InternetDetector:parseHost(host)
	local addr, port = host:match("^([^%[%]:]+):?(%d?%d?%d?%d?%d?)$")
	if not addr then
		addr, port = host:match("^%[?([^%[%]]+)%]?:?(%d?%d?%d?%d?%d?)$")
	end
	return addr, tonumber(port)
end

function InternetDetector:parseHosts()
	self.parsedHosts = {}
	for k, v in ipairs(self.serviceConfig.hosts) do
		local addr, port    = self:parseHost(v)
		self.parsedHosts[k] = { addr = addr, port = port }
	end
end

function InternetDetector:pingHost(host)
	local ping = string.format(
		"%s %s -W %d -s %d%s %s > /dev/null 2>&1",
		self.pingCmd,
		self.pingParams,
		self.serviceConfig.connection_timeout,
		self.serviceConfig.icmp_packet_size,
		self.serviceConfig.iface and (" -I " .. self.serviceConfig.iface) or "",
		host
	)
	local retCode = os.execute(ping)

	if self.debug then
		io.stdout:write(string.format(
			"--- Ping ---\ntime = %s\n%s\nretCode = %s\n", os.time(), ping, retCode)
		)
		io.stdout:flush()
	end

	return retCode
end

function InternetDetector:TCPConnectionToHost(host, port)
	local retCode = 1
	local saTable, errMsg, errNum = socket.getaddrinfo(host, port or self.serviceConfig.tcp_port)

	if not saTable then
		if self.debug then
			io.stdout:write(string.format(
				"GETADDRINFO ERROR: %s, %s\n", errMsg, errNum))
		end
	else
		local family = saTable[1].family
		if family then
			local sock, errMsg, errNum = socket.socket(family, socket.SOCK_STREAM, 0)

			if not sock then
				if self.debug then
					io.stdout:write(string.format(
						"SOCKET ERROR: %s, %s\n", errMsg, errNum))
				end
				return retCode
			end

			socket.setsockopt(sock, socket.SOL_SOCKET,
				socket.SO_SNDTIMEO, self.serviceConfig.connection_timeout, 0)
			socket.setsockopt(sock, socket.SOL_SOCKET,
				socket.SO_RCVTIMEO, self.serviceConfig.connection_timeout, 0)

			if self.serviceConfig.iface then
				local ok, errMsg, errNum = socket.setsockopt(sock, socket.SOL_SOCKET,
					socket.SO_BINDTODEVICE, self.serviceConfig.iface)
				if not ok then
					if self.debug then
						io.stdout:write(string.format(
							"SOCKET ERROR: %s, %s\n", errMsg, errNum))
					end

					unistd.close(sock)
					return retCode
				end
			end

			local success = socket.connect(sock, saTable[1])

			if self.debug then
				if not success then
					io.stdout:write(string.format(
						"SOCKET CONNECT ERROR: %s\n", tostring(success)))
				end
				local sockTable, err_s, e_s = socket.getsockname(sock)
				local peerTable, err_p, e_p = socket.getpeername(sock)
				if not sockTable then
					sockTable = {}
					io.stdout:write(
						string.format("SOCKET ERROR: %s, %s\n", err_s, e_s))
				end
				if not peerTable then
					peerTable = {}
					io.stdout:write(
						string.format("SOCKET ERROR: %s, %s\n", err_p, e_p))
				end
				io.stdout:write(string.format(
					"--- TCP ---\ntime = %s\nconnection_timeout = %s\niface = %s\nhost:port = [%s]:%s\nsockname = [%s]:%s\npeername = [%s]:%s\nsuccess = %s\n",
					os.time(),
					self.serviceConfig.connection_timeout,
					tostring(self.serviceConfig.iface),
					host,
					port or self.serviceConfig.tcp_port,
					tostring(sockTable.addr),
					tostring(sockTable.port),
					tostring(peerTable.addr),
					tostring(peerTable.port),
					tostring(success))
				)
				io.stdout:flush()
			end

			socket.shutdown(sock, socket.SHUT_RDWR)
			unistd.close(sock)
			retCode = success and 0 or 1
		end
	end
	return retCode
end

function InternetDetector:checkHosts()
	local checkFunc = (self.serviceConfig.check_type == 1) and self.pingHost or self.TCPConnectionToHost
	local retCode   = 1
	for k, v in ipairs(self.parsedHosts) do
		for i = 1, self.serviceConfig.connection_attempts do
			if checkFunc(self, v.addr, v.port) == 0 then
				retCode = 0
				break
			end
		end
		if retCode == 0 then
			break
		end
	end
	return retCode
end

function InternetDetector:breakMainLoop(signo)
	_RUNNING = false
end

function InternetDetector:resetUiCounter(signo)
	self.uiCounter = 0
end

function InternetDetector:mainLoop()
	signal.signal(signal.SIGTERM, function(signo) self:breakMainLoop(signo) end)
	signal.signal(signal.SIGINT, function(signo) self:breakMainLoop(signo) end)
	signal.signal(signal.SIGQUIT, function(signo) self:breakMainLoop(signo) end)
	signal.signal(signal.SIGUSR1, function(signo) self:resetUiCounter(signo) end)

	local lastStatus, currentStatus, mTimeNow, mTimeDiff, mLastTime, uiTimeNow, uiLastTime
	local interval = self.serviceConfig.interval_up
	local counter  = 0
	local onStart  = true
	_RUNNING       = true
	while _RUNNING do
		if counter == 0 or counter >= interval then
			currentStatus = self:checkHosts()
			if onStart or not stat.stat(self.statusFile) then
				self:writeValueToFile(self.statusFile, self:statusJson(
					currentStatus, self.serviceConfig.instance))
				onStart = false
			end

			if currentStatus == 0 then
				interval = self.serviceConfig.interval_up
				if lastStatus ~= nil and currentStatus ~= lastStatus then
					self:writeValueToFile(self.statusFile, self:statusJson(
						currentStatus, self.serviceConfig.instance))
					self:writeLogMessage("notice", "Connected")
				end
			else
				interval = self.serviceConfig.interval_down
				if lastStatus ~= nil and currentStatus ~= lastStatus then
					self:writeValueToFile(self.statusFile, self:statusJson(
						currentStatus, self.serviceConfig.instance))
					self:writeLogMessage("notice", "Disconnected")
				end
			end

			counter = 0
		end

		mTimeDiff = 0
		for _, e in ipairs(self.modules) do
			mTimeNow = time.clock_gettime(time.CLOCK_MONOTONIC).tv_sec
			if mLastTime then
				mTimeDiff = mTimeDiff + mTimeNow - mLastTime
			else
				mTimeDiff = 1
			end
			mLastTime = mTimeNow
			e:run(currentStatus, lastStatus, mTimeDiff)
		end

		local modulesStatus = {}
		for k, v in ipairs(self.modules) do
			if v.status ~= nil then
				modulesStatus[v.name] = v.status
			end
		end
		if next(modulesStatus) then
			self:writeValueToFile(self.statusFile, self:statusJson(
				currentStatus, self.serviceConfig.instance, modulesStatus))
		end

		lastStatus = currentStatus
		unistd.sleep(1)
		counter = counter + 1

		if self.mode == 2 then
			uiTimeNow = time.clock_gettime(time.CLOCK_MONOTONIC).tv_sec
			if uiLastTime then
				self.uiCounter = self.uiCounter + uiTimeNow - uiLastTime
			else
				self.uiCounter = self.uiCounter + 1
			end
			uiLastTime = uiTimeNow

			if self.uiCounter >= self.uiRunTime then
				self:breakMainLoop(signal.SIGTERM)
			end
		end
	end
end

function InternetDetector:removeProcessFiles()
	os.remove(string.format(
		"%s/%s.%s.pid", self.commonDir, self.appName, self.serviceConfig.instance))
	os.remove(string.format(
		"%s/%s.%s.status", self.commonDir, self.appName, self.serviceConfig.instance))
end

function InternetDetector:status()
	local ok, commonDir = pcall(dirent.files, self.commonDir)
	if ok then
		local appName = self.appName:gsub("-", "%%-")
		for item in commonDir do
			if item:match("^" .. appName .. ".-%.pid$") then
				return "running"
			end
		end
	end
	return "stoped"
end

function InternetDetector:inetStatus()
	local inetStat      = '{"instances":[]}'
	local ok, commonDir = pcall(dirent.files, self.commonDir)
	if ok then
		local appName = self.appName:gsub("-", "%%-")
		local lines   = {}
		for item in commonDir do
			if item:match("^" .. appName .. ".-%.status$") then
				lines[#lines + 1] = self:readValueFromFile(
					string.format("%s/%s", self.commonDir, item))
			end
		end
		inetStat = '{"instances":[' .. table.concat(lines, ",") .. "]}"
	end
	return inetStat
end

function InternetDetector:stopInstance(pidFile)
	local retVal
	if stat.stat(pidFile) then
		pidValue = self:readValueFromFile(pidFile)
		if pidValue then
			local ok, errMsg, errNum
			for i = 0, 10 do
				ok, errMsg, errNum = signal.kill(tonumber(pidValue), signal.SIGTERM)
				if ok then
					break
				end
			end
			if not ok then
				io.stderr:write(string.format(
					'Process stopping error: %s (%s). PID: "%s"\n', errMsg, errNum, pidValue))
			end
			if errNum == 3 then
				os.remove(pidFile)
			end
			retVal = true
		end
	end
	if not pidValue then
		io.stderr:write(
			string.format('PID file "%s" does not exists. Is the %s not running?\n',
				pidFile, self.appName))
	end
	return retVal
end

function InternetDetector:stop()
	local appName = self.appName:gsub("-", "%%-")
	local success
	for i = 0, 10 do
		success = true
		local ok, commonDir = pcall(dirent.files, self.commonDir)
		if ok then
			for item in commonDir do
				if item:match("^" .. appName .. ".-%.pid$") then
					self:stopInstance(string.format("%s/%s", self.commonDir, item))
					success = false
				end
			end
			if success then
				break
			end
			unistd.sleep(1)
		else
			break
		end
	end
end

function InternetDetector:setSIGUSR()
	local appName = self.appName:gsub("-", "%%-")
	local ok, commonDir = pcall(dirent.files, self.commonDir)
	if ok then
		for item in commonDir do
			if item:match("^" .. appName .. ".-%.pid$") then
				pidValue = self:readValueFromFile(string.format("%s/%s", self.commonDir, item))
				if pidValue then
					signal.kill(tonumber(pidValue), signal.SIGUSR1)
				end
			end
		end
	end
end

function InternetDetector:preRun()
	-- Exit if internet-detector mode != (1 or 2)
	if self.mode ~= 1 and self.mode ~= 2 then
		io.stderr:write(string.format('Start failed, mode != (1 or 2)\n', self.appName))
		os.exit(0)
	end
	if stat.stat(self.pidFile) then
		io.stderr:write(
			string.format('PID file "%s" exists. Is the %s already running?\n',
				self.pidFile, self.appName))
		return false
	end
	return true
end

function InternetDetector:run()
	local pidValue = unistd.getpid()
	self:writeValueToFile(self.pidFile, pidValue)
	if self.enableLogger then
		syslog.openlog(self.appName, syslog.LOG_PID, syslog.LOG_DAEMON)
	end
	self:writeLogMessage("info", "started")
	self:loadModules()

	-- Loaded modules
	local modules = {}
	for _, v in ipairs(self.modules) do
		modules[#modules + 1] = string.format("%s", v.name)
	end
	if #modules > 0 then
		self:writeLogMessage(
			"info", string.format("Loaded modules: %s", table.concat(modules, ", "))
		)
	end

	if self.debug then
		local function inspectTable()
			local tables = {}, f
			f = function(t, prefix)
				tables[t] = true
				for k, v in pairs(t) do
					io.stdout:write(string.format(
						"%s%s = %s\n", prefix, k, tostring(v))
					)
					if type(v) == "table" and not tables[v] then
						f(v, string.format("%s%s.", prefix, k))
					end
				end
			end
			return f
		end

		io.stdout:write("--- Config ---\n")
		inspectTable()(self, "self.")
		io.stdout:flush()
	end

	self:writeValueToFile(
		self.statusFile, self:statusJson(-1, self.serviceConfig.instance))

	self:mainLoop()

	self:removeProcessFiles()
	if self.enableLogger then
		self:writeLogMessage("info", "stoped")
		syslog.closelog()
	end
end

function InternetDetector:noDaemon()
	if not self:preRun() then
		return
	end
	self:run()
end

function InternetDetector:daemon()
	if not self:preRun() then
		return
	end
	-- UNIX double fork
	if unistd.fork() == 0 then
		unistd.setpid("s")
		if unistd.fork() == 0 then
			unistd.chdir("/")
			stat.umask(0)
			local devnull = fcntl.open("/dev/null", fcntl.O_RDWR)
			io.stdout:flush()
			io.stderr:flush()
			unistd.dup2(devnull, 0)	-- io.stdin
			unistd.dup2(devnull, 1)	-- io.stdout
			unistd.dup2(devnull, 2)	-- io.stderr
			self:run()
			unistd.close(devnull)
		end
		os.exit(0)
	end
	os.exit(0)
end

function InternetDetector:setServiceConfig(instance)
	if self:loadUCIConfig("instance", instance) then
		self:parseHosts()
		if self.mode == 2 then
			self.enableLogger = false
			self.noModules    = true
		end
		return true
	end
end

return InternetDetector
