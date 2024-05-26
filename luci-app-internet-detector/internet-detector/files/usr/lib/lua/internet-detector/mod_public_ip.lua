
local socket = require("posix.sys.socket")
local stdlib = require("posix.stdlib")
local unistd = require("posix.unistd")

local Module = {
	name              = "mod_public_ip",
	runPrio           = 50,
	config            = {
		noModules = false,
		debug     = false,
		serviceConfig = {
			iface = nil,
		},
	},
	syslog            = function(level, msg) return true end,
	writeValue        = function(filePath, str) return false end,
	readValue         = function(filePath) return nil end,
	port              = 53,
	runInterval       = 600,
	runIntervalFailed = 60,
	timeout           = 3,
	providers         = {
		opendns1 = {
			name = "opendns1", host = "myip.opendns.com",
			server = "208.67.222.222", server6 = "2620:119:35::35",
			port = 53, queryType = "A", queryType6 = "AAAA",
		},
		opendns2 = {
			name = "opendns2", host = "myip.opendns.com",
			server = "208.67.220.220", server6 = "2620:119:35::35",
			port = 53, queryType = "A", queryType6 = "AAAA",
		},
		opendns3 = {
			name = "opendns3", host = "myip.opendns.com",
			server = "208.67.222.220", server6 = "2620:119:35::35",
			port = 53, queryType = "A", queryType6 = "AAAA",
		},
		opendns4 = {
			name = "opendns4", host = "myip.opendns.com",
			server = "208.67.220.222", server6 = "2620:119:35::35",
			port = 53, queryType = "A", queryType6 = "AAAA",
		},
		akamai   = {
			name = "akamai", host = "whoami.akamai.net",
			server = "ns1-1.akamaitech.net", server6 = "ns1-1.akamaitech.net",
			port = 53, queryType = "A", queryType6 = "AAAA",
		},
		google   = {
			name = "google", host = "o-o.myaddr.l.google.com",
			server = "ns1.google.com", server6 = "ns1.google.com",
			port = 53, queryType = "TXT", queryType6 = "TXT",
		},
	},
	ipScript          = "",
	enableIpScript    = false,
	status            = nil,
	_provider         = nil,
	_qtype            = false,
	_currentIp        = nil,
	_enabled          = false,
	_counter          = 0,
	_interval         = 600,
	_DNSPacket        = nil,
}

function Module:runIpScript()
	if not self.config.noModules and self.enableIpScript and unistd.access(self.ipScript, "r") then
		stdlib.setenv("PUBLIC_IP", self.status)
		os.execute(string.format('/bin/sh "%s" &', self.ipScript))
	end
end

function Module:getQueryType(type)
	local types = {
		A     = 1,
		NS    = 2,
		MD    = 3,
		MF    = 4,
		CNAME = 5,
		SOA   = 6,
		MB    = 7,
		MG    = 8,
		MR    = 9,
		NULL  = 10,
		WKS   = 11,
		PTS   = 12,
		HINFO = 13,
		MINFO = 14,
		MX    = 15,
		TXT   = 16,
		AAAA  = 28,
	}
	return types[type]
end

function Module:buildMessage(address, queryType)
	if not queryType then
		queryType = "A"
	end
	queryType = self:getQueryType(queryType)

	local addressString = ""
	for part in address:gmatch("[^.]+") do
		local t = {}
		for i in part:gmatch(".") do
			t[#t + 1] = i
		end
		addrLen       = #part
		addrPart      = table.concat(t)
		addressString = addressString .. string.char(addrLen) .. addrPart
	end

	local data = (
		string.char(
			0xaa, 0xaa,
			0x01, 0x00,
			0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
		) ..
		addressString ..
		string.char(
			0x00,
			0x00, queryType,
			0x00, 0x01
		)
	)
	return data
end

function Module:sendUDPMessage(message, server, port)
	local success
	local retCode = 1
	local data

	if self.config.debug then
		io.stdout:write(string.format("--- %s ---\n", self.name))
		io.stdout:flush()
	end

	local saTable, errMsg, errNum = socket.getaddrinfo(server, port)

	if not saTable then
		if self.config.debug then
			io.stdout:write(string.format(
				"GETADDRINFO ERROR: %s, %s\n", errMsg, errNum))
		end
	else
		local family = saTable[1].family

		if family then
			local sock, errMsg, errNum = socket.socket(family, socket.SOCK_DGRAM, 0)

			if not sock then
				if self.config.debug then
					io.stdout:write(string.format(
						"SOCKET ERROR: %s, %s\n", errMsg, errNum))
				end
				return retCode
			end

			socket.setsockopt(sock, socket.SOL_SOCKET,
				socket.SO_SNDTIMEO, self.timeout, 0)
			socket.setsockopt(sock, socket.SOL_SOCKET,
				socket.SO_RCVTIMEO, self.timeout, 0)

			if self.config.serviceConfig.iface then
				local ok, errMsg, errNum = socket.setsockopt(sock, socket.SOL_SOCKET,
					socket.SO_BINDTODEVICE, self.config.serviceConfig.iface)
				if not ok then
					if self.config.debug then
						io.stdout:write(string.format(
							"SOCKET ERROR: %s, %s\n", errMsg, errNum))
					end
					unistd.close(sock)
					return retCode
				end
			end

			local ok, errMsg, errNum = socket.sendto(sock, message, saTable[1])
			local response = {}
			if ok then
				local ret, resp, errNum = socket.recvfrom(sock, 1024)
				data = ret
				if data then
					success  = true
					response = resp
				elseif self.config.debug then
					io.stdout:write(string.format(
						"SOCKET RECV ERROR: %s, %s\n", tostring(resp), tostring(errNum)))
				end
			elseif self.config.debug then
				io.stdout:write(string.format(
					"SOCKET SEND ERROR: %s, %s\n", tostring(errMsg), tostring(errNum)))
			end

			if self.config.debug then
				io.stdout:write(string.format(
					"--- UDP ---\ntime = %s\nconnection_timeout = %s\niface = %s\nserver = %s:%s\nsockname = %s:%s\nsuccess = %s\n",
					os.time(),
					self.timeout,
					tostring(self.config.serviceConfig.iface),
					server,
					tostring(port),
					tostring(response.addr),
					tostring(response.port),
					tostring(success))
				)
				io.stdout:flush()
			end

			unistd.close(sock)
			retCode = success and 0 or 1
		end
	end
	return retCode, tostring(data)
end

function Module:parseParts(message, start, parts)
	local partStart = start + 2
	local partLen   = message:sub(start, start + 1)

	if #partLen == 0 then
		return parts
	end

	local partEnd     = partStart + (tonumber(partLen, 16) * 2)

	parts[#parts + 1] = message:sub(partStart, partEnd - 1)
	if message:sub(partEnd, partEnd + 1) == "00" or partEnd > #message then
		return parts
	else
		return self:parseParts(message, partEnd, parts)
	end
end

function Module:decodeMessage(message)
	local retTable = {}
	local t = {}
	for i = 1, #message do
		t[#t + 1] = string.format("%.2x", string.byte(message, i))
	end
	message = table.concat(t)

	local ANCOUNT = message:sub(13, 16)
	local NSCOUNT = message:sub(17, 20)
	local ARCOUNT = message:sub(21, 24)

	local questionSectionStarts = 25
	local questionParts = self:parseParts(message, questionSectionStarts, {})
	local qtypeStarts   = questionSectionStarts + (#table.concat(questionParts)) + (#questionParts * 2) + 1
	local qclassStarts  = qtypeStarts + 4

	local answerSectionStarts = qclassStarts + 4
	local numAnswers          = math.max(
		tonumber(ANCOUNT, 16), tonumber(NSCOUNT, 16), tonumber(ARCOUNT, 16))

	if numAnswers > 0 then
		for answerCount = 1, numAnswers do

			if answerSectionStarts < #message then
				local ATYPE = tonumber(
					message:sub(answerSectionStarts + 5, answerSectionStarts + 8), 16)
				local RDLENGTH = tonumber(
					message:sub(answerSectionStarts + 21, answerSectionStarts + 24), 16)
				local RDDATA = message:sub(
					answerSectionStarts + 25, answerSectionStarts + 24 + (RDLENGTH * 2))
				local RDDATA_decoded = ""

				if #RDDATA > 0 then
					if ATYPE == self:getQueryType("A") or ATYPE == self:getQueryType("AAAA") then
						local octets = {}
						local sep    = "."
						if #RDDATA > 8 then
							sep = ":"
							for i = 1, #RDDATA, 4 do
								local string = RDDATA:sub(i, i + 3)
								string = string:gsub("^00?0?", "")
								octets[#octets + 1] = string
							end
						else
							for i = 1, #RDDATA, 2 do
								octets[#octets + 1] = tonumber(RDDATA:sub(i, i + 1), 16)
							end
						end
						RDDATA_decoded = table.concat(octets, sep):gsub("0:[0:]+", "::", 1):gsub("::+", "::")
					else
						local rdata_t = {}
						for _, v in ipairs(self:parseParts(RDDATA, 1, {})) do
							local t = {}
							for i = 1, #v, 2 do
								t[#t + 1] = string.char(tonumber(v:sub(i, i + 1), 16))
							end
							rdata_t[#rdata_t + 1] = table.concat(t)
						end
						RDDATA_decoded = table.concat(rdata_t)
					end
				end
				answerSectionStarts = answerSectionStarts + 24 + (RDLENGTH * 2)

				if RDDATA_decoded:match("^[a-f0-9.:]+$") then
					retTable[#retTable + 1] = RDDATA_decoded
				end
			end
		end
	end

	return retTable
end

function Module:resolveIP()
	local res
	local qtype  = self._qtype and self._provider.queryType6 or self._provider.queryType
	local server = self._qtype and self._provider.server6 or self._provider.server
	local port   = self._provider.port or self.port

	if not self._DNSPacket then
		self._DNSPacket = self:buildMessage(self._provider.host, qtype)
	end

	local retCode, response = self:sendUDPMessage(self._DNSPacket, server, port)
	if retCode == 0 then
		local retTable = self:decodeMessage(response)
		if #retTable > 0 then
			res = table.concat(retTable, ", ")
		end
	else
		self.syslog("err", string.format(
			"%s: DNS error when requesting an IP address", self.name))
	end

	return res
end

function Module:init(t)
	if t.interval ~= nil then
		self.runInterval = tonumber(t.interval)
	end
	if t.timeout ~= nil then
		self.timeout = tonumber(t.timeout)
	end
	if t.provider ~= nil then
		self._provider = self.providers[t.provider]
	else
		self._provider = self.providers.opendns1
	end
	if self.config.configDir then
		self.ipScript = string.format(
			"%s/public-ip-script.%s", self.config.configDir, self.config.serviceConfig.instance)
		if t.enable_ip_script ~= nil then
			self.enableIpScript = (tonumber(t.enable_ip_script) ~= 0)
		end
	end
	if t.qtype ~= nil then
		self._qtype = (tonumber(t.qtype) ~= 0)
	end
	self._currentIp = nil
	self._DNSPacket = nil
	self._interval  = self.runInterval
	self._enabled   = true
end

function Module:run(currentStatus, lastStatus, timeDiff)
	if not self._enabled then
		return
	end
	if currentStatus == 0 then
		if self._counter == 0 or self._counter >= self._interval or currentStatus ~= lastStatus then

			local ip = self:resolveIP()

			if not ip then
				ip = ""
				self._interval = self.runIntervalFailed
			else
				self._interval = self.runInterval
			end

			if ip ~= self._currentIp then
				self.status = ip
				self.syslog(
					"notice",
					string.format("%s: public IP address %s", self.name, (ip == "") and "Undefined" or ip)
				)
				if self._counter > 0 then
					self:runIpScript()
				end
			else
				self.status = nil
			end

			self._currentIp = ip
			self._counter   = 0
		else
			self.status = nil
		end
	else
		self.status     = nil
		self._currentIp = nil
		self._counter   = 0
		self._interval  = self.runInterval
	end

	self._counter = self._counter + timeDiff
end

return Module
