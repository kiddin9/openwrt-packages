
local unistd = require("posix.unistd")
local dirent = require("posix.dirent")

local Module = {
	name                  = "mod_led_control",
	runPrio               = 10,
	config                = {},
	syslog                = function(level, msg) return true end,
	writeValue            = function(filePath, str) return false end,
	readValue             = function(filePath) return nil end,
	runInterval           = 5,
	sysLedsDir            = "/sys/class/leds",
	ledName               = nil,
	ledAction1            = 2,		-- 1: off, 2: on, 3: blink
	ledAction2            = 1,		-- 1: off, 2: on, 3: blink
	status                = nil,
	_enabled              = false,
	_ledDir               = nil,
	_ledMaxBrightnessFile = nil,
	_ledBrightnessFile    = nil,
	_ledMaxBrightness     = nil,
	_ledTriggerFile       = nil,
	_counter              = 0,
}

function Module:resetLeds()
	local ok, dir = pcall(dirent.files, self.sysLedsDir)
	if not ok then
		return
	end
	for led in dir do
		local brightness = string.format("%s/%s/brightness", self.sysLedsDir, led)
		if unistd.access(brightness, "w") then
			self.writeValue(brightness, 0)
		end
	end
end

function Module:init(t)
	if not t.led_name then
		return
	else
		self.ledName = t.led_name
	end
	if t.led_action_1 ~= nil then
		self.ledAction1 = tonumber(t.led_action_1)
	end
	if t.led_action_2 ~= nil then
		self.ledAction2 = tonumber(t.led_action_2)
	end
	self._ledDir               = string.format("%s/%s", self.sysLedsDir, self.ledName)
	self._ledMaxBrightnessFile = string.format("%s/max_brightness", self._ledDir)
	self._ledBrightnessFile    = string.format("%s/brightness", self._ledDir)
	self._ledMaxBrightness     = self.readValue(self._ledMaxBrightnessFile) or 1
	self._ledTriggerFile       = string.format("%s/trigger", self._ledDir)

	if (not unistd.access(self._ledDir, "r") or
	    not unistd.access(self._ledBrightnessFile, "rw") or
	    not unistd.access(self._ledTriggerFile, "rw")) then
		self._enabled = false
		self.syslog("warning", string.format(
			"%s: LED '%s' is not available", self.name, self.ledName))
	else
		self._enabled = true
		-- Reset all LEDs
		--self:resetLeds()
	end
end

function Module:SetTriggerTimer()
	self.writeValue(self._ledTriggerFile, "timer")
end

function Module:SetTriggerNone()
	self.writeValue(self._ledTriggerFile, "none")
end

function Module:getCurrentTrigger()
	local trigger = self.readValue(self._ledTriggerFile)
	if trigger and trigger:match("%[timer%]") then
		return 1
	end
end

function Module:on()
	self:SetTriggerNone()
	self.writeValue(self._ledBrightnessFile, self._ledMaxBrightness)
end

function Module:off()
	self:SetTriggerNone()
	self.writeValue(self._ledBrightnessFile, 0)
end

function Module:getCurrentState()
	local state = self.readValue(self._ledBrightnessFile)
	if state and tonumber(state) > 0 then
		return tonumber(state)
	end
end

function Module:run(currentStatus, lastStatus, timeDiff)
	if not self._enabled then
		return
	end
	if self._counter == 0 or self._counter >= self.runInterval or currentStatus ~= lastStatus then
		if currentStatus == 0 then
			if self.ledAction1 == 1 then
				if self:getCurrentState() or self:getCurrentTrigger() then
					self:off()
				end
			elseif self.ledAction1 == 2 then
				if not self:getCurrentState() or self:getCurrentTrigger() then
					self:on()
				end
			elseif self.ledAction1 == 3 then
				if not self:getCurrentTrigger() then
					self:SetTriggerTimer()
				end
			end
		else
			if self.ledAction2 == 1 then
				if self:getCurrentState() or self:getCurrentTrigger() then
					self:off()
				end
			elseif self.ledAction2 == 2 then
				if not self:getCurrentState() or self:getCurrentTrigger() then
					self:on()
				end
			elseif self.ledAction2 == 3 then
				if not self:getCurrentTrigger() then
					self:SetTriggerTimer()
				end
			end
		end
		self._counter = 0
	end
	self._counter = self._counter + timeDiff
end

return Module
