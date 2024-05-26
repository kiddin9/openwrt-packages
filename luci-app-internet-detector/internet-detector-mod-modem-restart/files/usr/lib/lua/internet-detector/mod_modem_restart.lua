--[[
	Dependences:
		modemmanager
--]]
local unistd = require("posix.unistd")

local Module = {
	name         = "mod_modem_restart",
	runPrio      = 40,
	config       = {},
	syslog       = function(level, msg) return true end,
	writeValue   = function(filePath, str) return false end,
	readValue    = function(filePath) return nil end,
	mmcli        = "/usr/bin/mmcli",
	mmInit       = "/etc/init.d/modemmanager",
	deadPeriod   = 600,
	iface        = nil,
	anyBand      = false,
	status       = nil,
	_enabled     = false,
	_deadCounter = 0,
	_restarted   = false,
}

function Module:toggleIface(flag)
	if not self.iface then
		return
	end
	return os.execute(
		string.format("%s %s", (flag and "/sbin/ifup" or "/sbin/ifdown"), self.iface)
	)
end

function Module:restartMM()
	if os.execute(string.format("%s enabled", self.mmInit)) ~= 0 then
		self.syslog("warning", string.format(
			"%s: modemmanager service is disabled", self.name))
		return
	end

	if self.anyBand then
		self.syslog("info", string.format(
			"%s: resetting current-bands to 'any'", self.name))
		os.execute(string.format("%s -m any --set-current-bands=any", self.mmcli))
	end

	self.syslog("info", string.format("%s: reconnecting modem", self.name))
	os.execute(string.format("%s restart", self.mmInit))

	if self.iface then
		self.syslog("info", string.format(
			"%s: restarting network interface '%s'", self.name, self.iface))
		self:toggleIface(false)
		self:toggleIface(true)
	end
end

function Module:init(t)
	if t.dead_period ~= nil then
		self.deadPeriod = tonumber(t.dead_period)
	end
	if t.iface ~= nil then
		self.iface = t.iface
	end
	if t.any_band ~= nil then
		self.anyBand = (tonumber(t.any_band) ~= 0)
	end

	if not unistd.access(self.mmcli, "x") then
		self.anyBand = false
	end

	if (unistd.access(self.mmInit, "x")
		and os.execute(string.format("%s enabled", self.mmInit)) == 0) then
		self._enabled = true
	else
		self._enabled = false
		self.syslog("warning", string.format(
			"%s: modemmanager service is not available", self.name))
	end
end

function Module:run(currentStatus, lastStatus, timeDiff)
	if not self._enabled then
		return
	end
	if currentStatus == 1 then
		if not self._restarted then
			if self._deadCounter >= self.deadPeriod then
				self:restartMM()
				self._restarted = true
			else
				self._deadCounter = self._deadCounter + timeDiff
			end
		end
	else
		self._deadCounter = 0
		self._restarted   = false
	end
end

return Module
