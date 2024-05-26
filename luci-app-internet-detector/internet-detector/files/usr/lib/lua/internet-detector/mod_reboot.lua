
local unistd = require("posix.unistd")

local Module = {
	name             = "mod_reboot",
	runPrio          = 20,
	config           = {},
	syslog           = function(level, msg) return true end,
	writeValue       = function(filePath, str) return false end,
	readValue        = function(filePath) return nil end,
	deadPeriod       = 3600,
	forceRebootDelay = 300,
	status           = nil,
	_deadCounter     = 0,
}

function Module:rebootDevice()
	self.syslog("warning", string.format("%s: reboot", self.name))
	os.execute("/sbin/reboot &")
	if self.forceRebootDelay > 0 then
		unistd.sleep(self.forceRebootDelay)
		self.syslog("warning", string.format("%s: force reboot", self.name))
		self.writeValue("/proc/sys/kernel/sysrq", "1")
		self.writeValue("/proc/sysrq-trigger", "b")
	end
end

function Module:init(t)
	if t.dead_period ~= nil then
		self.deadPeriod  = tonumber(t.dead_period)
	end
	if t.force_reboot_delay ~= nil then
		self.forceRebootDelay = tonumber(t.force_reboot_delay)
	end
end

function Module:run(currentStatus, lastStatus, timeDiff)
	if currentStatus == 1 then
		if self._deadCounter >= self.deadPeriod then
			self:rebootDevice()
			self._deadCounter = 0
		else
			self._deadCounter = self._deadCounter + timeDiff
		end

	else
		self._deadCounter = 0
	end
end

return Module
