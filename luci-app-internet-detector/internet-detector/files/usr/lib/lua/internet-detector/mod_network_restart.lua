
local unistd = require("posix.unistd")

local Module = {
	name             = "mod_network_restart",
	runPrio          = 30,
	config           = {},
	syslog           = function(level, msg) return true end,
	writeValue       = function(filePath, str) return false end,
	readValue        = function(filePath) return nil end,
	deadPeriod       = 900,
	attempts         = 1,
	iface            = nil,
	restartTimeout   = 0,
	status           = nil,
	_attemptsCounter = 0,
	_deadCounter     = 0,
}

function Module:toggleFunc(flag)
	return
end

function Module:toggleDevice(flag)
	if not self.iface then
		return
	end
	local ip = "/sbin/ip"
	if unistd.access(ip, "x") then
		return os.execute(string.format(
			"%s link set dev %s %s", ip, self.iface, (flag and "up" or "down"))
		)
	end
end

function Module:toggleIface(flag)
	if not self.iface then
		return
	end
	return os.execute(
		string.format("%s %s", (flag and "/sbin/ifup" or "/sbin/ifdown"), self.iface)
	)
end

function Module:ifaceUp()
	self:toggleFunc(true)
end

function Module:ifaceDown()
	self:toggleFunc(false)
end

function Module:networkRestart()
	return os.execute("/etc/init.d/network restart")
end

function Module:init(t)
	local iface = t.iface
	if iface then
		self.iface = iface
		if self.iface:match("^@") then
			self.iface      = self.iface:gsub("^@", "")
			self.toggleFunc = self.toggleIface
		else
			self.toggleFunc = self.toggleDevice
		end
	end
	if t.attempts ~= nil then
		self.attempts = tonumber(t.attempts)
	end
	if t.dead_period ~= nil then
		self.deadPeriod = tonumber(t.dead_period)
	end
	if t.restart_timeout ~= nil then
		self.restartTimeout = tonumber(t.restart_timeout)
	end
end

function Module:run(currentStatus, lastStatus, timeDiff)
	if currentStatus == 1 then
		if self.attempts == 0 or self._attemptsCounter < self.attempts then
			if self._deadCounter >= self.deadPeriod then
				if self.iface then
					self.syslog("info", string.format(
						"%s: restarting network interface '%s'", self.name, self.iface))
					self:ifaceDown()
					unistd.sleep(self.restartTimeout)
					self:ifaceUp()
				else
					self.syslog("info", string.format(
						"%s: restarting network", self.name))
					self:networkRestart()
				end
				self._deadCounter     = 0
				self._attemptsCounter = self._attemptsCounter + 1
			else
				self._deadCounter = self._deadCounter + timeDiff
			end
		end
	else
		self._attemptsCounter = 0
		self._deadCounter     = 0
	end
end

return Module
