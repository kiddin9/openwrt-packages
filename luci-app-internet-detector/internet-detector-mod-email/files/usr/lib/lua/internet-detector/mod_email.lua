--[[
	Dependences:
		mailsend
--]]
local unistd = require("posix.unistd")

local Module = {
	name               = "mod_email",
	runPrio            = 60,
	config             = {
		debug = false,
	},
	syslog             = function(level, msg) return true end,
	writeValue         = function(filePath, str) return false end,
	readValue          = function(filePath) return nil end,
	deadPeriod         = 0,
	alivePeriod        = 0,
	mode               = 0,		-- 0: connected, 1: disconnected, 2: both
	hostAlias          = "OpenWrt",
	mta                = "/usr/bin/mailsend",
	mtaConnectTimeout  = 5,		-- default = 5
	mtaReadTimeout     = 5,		-- default = 5
	mailRecipient      = nil,
	mailSender         = nil,
	mailUser           = nil,
	mailPassword       = nil,
	mailSmtp           = nil,
	mailSmtpPort       = nil,
	mailSecurity       = "tls",
	msgTextPattern1    = "[%s]: %s: %s",	-- Connected (host, instance, message)
	msgTextPattern2    = "[%s]: %s: %s",	-- Disconnected (host, instance, message)
	msgSubPattern      = "%s notification", -- Subject (host)
	status             = nil,
	_enabled           = false,
	_deadCounter       = 0,
	_aliveCounter      = 0,
	_msgSentDisconnect = true,
	_msgSentConnect    = true,
	_disconnected      = true,
	_lastDisconnection = nil,
	_lastConnection    = nil,
	_message           = {},
}

function Module:init(t)
	if t.mode ~= nil then
		self.mode = tonumber(t.mode)
	end
	if t.dead_period ~= nil then
		self.deadPeriod = tonumber(t.dead_period)
	end
	if t.alive_period ~= nil then
		self.alivePeriod = tonumber(t.alive_period)
	end
	if t.host_alias then
		self.hostAlias = t.host_alias
	else
		self.hostAlias = self.config.hostname
	end

	self.mailRecipient = t.mail_recipient
	self.mailSender    = t.mail_sender
	self.mailUser      = t.mail_user
	self.mailPassword  = t.mail_password
	self.mailSmtp      = t.mail_smtp
	self.mailSmtpPort  = t.mail_smtp_port

	if t.mail_security ~= nil then
		self.mailSecurity = t.mail_security
	end

	if unistd.access(self.mta, "x") then
		self._enabled = true
	else
		self._enabled = false
		self.syslog("warning", string.format("%s: %s is not available", self.name, self.mta))
	end

	if (not self.mailRecipient or
	    not self.mailSender or
	    not self.mailUser or
	    not self.mailPassword or
	    not self.mailSmtp or
	    not self.mailSmtpPort) then
		self._enabled = false
		self.syslog("warning", string.format(
			"%s: Insufficient data to connect to the SMTP server", self.name))
	end
end

function Module:sendMessage(msg, textPattern)
	local verboseArg = ""
	local emailMsg   = string.format(
		textPattern, self.hostAlias, self.config.serviceConfig.instance, msg)

	-- Debug
	if self.config.debug then
		verboseArg = " -v"
		io.stdout:write(string.format("--- %s ---\n", self.name))
		io.stdout:flush()
	end

	local securityArgs = "-starttls -auth-login"
	if self.mailSecurity == "ssl" then
		securityArgs = "-ssl -auth"
	end

	local mtaCmd = string.format(
		'%s%s %s -smtp "%s" -port %s -ct %s -read-timeout %s -cs utf-8 -user "%s" -pass "%s" -f "%s" -t "%s" -sub "%s" -M "%s"',
		self.mta, verboseArg, securityArgs, self.mailSmtp, self.mailSmtpPort,
		self.mtaConnectTimeout, self.mtaReadTimeout,
		self.mailUser, self.mailPassword, self.mailSender, self.mailRecipient,
		string.format(self.msgSubPattern, self.hostAlias),
		emailMsg)

	-- Debug
	if self.config.debug then
		io.stdout:write(string.format("%s: %s\n", self.name, mtaCmd))
		io.stdout:flush()
		self.syslog("debug", string.format("%s: %s", self.name, mtaCmd))
	end

	if os.execute(mtaCmd) ~= 0 then
		self.syslog("err", string.format(
			"%s: An error occured while sending message", self.name))
	else
		self.syslog("info", string.format(
			"%s: Message sent to %s", self.name, self.mailRecipient))
	end
end

function Module:run(currentStatus, lastStatus, timeDiff)
	if not self._enabled then
		return
	end
	if currentStatus == 1 then
		self._aliveCounter   = 0
		self._msgSentConnect = false
		self._lastConnection = nil
		if not self._disconnected then
			self._disconnected = true
			if not self._lastDisconnection then
				self._lastDisconnection = os.date("%Y.%m.%d %H:%M:%S", os.time())
			end
			self._message[#self._message + 1] = string.format(
				"Internet disconnected: %s", self._lastDisconnection)
		end
		if not self._msgSentDisconnect and (self.mode == 1 or self.mode == 2) then
			if self._deadCounter >= self.deadPeriod then
				self._lastDisconnection = nil
				self:sendMessage(table.concat(self._message, "; "), self.msgTextPattern2)
				self._message           = {}
				self._msgSentDisconnect = true
			else
				self._deadCounter = self._deadCounter + timeDiff
			end
		end
	else
		self._deadCounter       = 0
		self._msgSentDisconnect = false
		if not self._msgSentConnect and (self.mode == 0 or self.mode == 2) then
			if not self._lastConnection then
				self._lastConnection = os.date("%Y.%m.%d %H:%M:%S", os.time())
			end
			if self._aliveCounter >= self.alivePeriod then
				self._message[#self._message + 1] = string.format(
						"Internet connected: %s", self._lastConnection)
				self:sendMessage(table.concat(self._message, "; "), self.msgTextPattern1)
				self._message        = {}
				self._msgSentConnect = true
			else
				self._aliveCounter = self._aliveCounter + timeDiff
			end
		end
		self._disconnected = false
	end
end

return Module
