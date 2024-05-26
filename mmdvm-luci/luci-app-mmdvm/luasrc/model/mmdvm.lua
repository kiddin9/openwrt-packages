-- Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

local util  = require "luci.util"
local fs = require "nixio.fs"
local json = require "luci.jsonc"
local ini = require "luci.ini"
local os = os
local io = io
local table = table
local string = string
local tonumber  = tonumber
local print = print
local type = type
local assert = assert
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local getmetatable = getmetatable

local uci   = require("luci.model.uci").cursor()

module "luci.model.mmdvm"

MMDVMHOST_CONFFILE = "/etc/MMDVM.ini"
YSFGATEWAY_CONFFILE = "/etc/YSFGateway.ini"
P25GATEWAY_CONFFILE = "/etc/P25Gateway.ini"
NXDNGATEWAY_CONFFILE = "/etc/NXDNGateway.ini"
DAPNETGATEWAY_CONFFILE = "/etc/DAPNETGateway.ini"
IRCDDBGATEWAY_CONFFILE = "/etc/ircddbgateway"
UCI_CONFFILE = "/etc/config/mmdvm"

function pocsag_enabled()
	return uci:get('mmdvm', 'POCSAG', 'Enable') == '1'
		and fs.access("/etc/init.d/dapnetgateway")
end

--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function ini_load(fileName)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.')
	return ini.parse(fileName)
end

--- Saves all the data from a table to an INI file.
--@param fileName The name of the INI file to fill. [string]
--@param data The table containing all the data to store. [table]
function ini_save(fileName, data)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.')
	assert(type(data) == 'table', 'Parameter "data" must be a table.')
	ini.save(fileName, data)
end

--- Ini to uci synchornize
--- When ini file is updated manualy, the uci file will be sync by running this function
-- @params muci uci instance, typically ref of a Map.uci at cbi
function ini2uci(muci)
	-- http.write_json(conf)
	local mmdvmhost_conf_setions_needed = {
			General = {"Callsign", "Id", "Duplex", "NetModeHang", "RFModeHang"}, 
			Info = {"RXFrequency", "TXFrequency", "Latitude", "Longitude", "Power", "Height", "Location", "Description", "URL"}, 
			Modem = {"Port", "RXOffset", "TXOffset", "RSSIMappingFile"}, 
			DMR = {"Enable", "ColorCode", "SelfOnly", "DumpTAData"}, 
			DMR_Network = {"Address", "Password"}, 
			System_Fusion = {"Enable", "SelfOnly"}, 
			System_Fusion_Network = {"Enable"},
			P25 = {"Enable", "NAC", "SelfOnly", "OverrideUIDCheck"},
			P25_Network = {"Enable"},
			NXDN = {"Enable"}, 
			NXDN_Network = {"Enable"},
			POCSAG = {"Enable", "Frequency"}, 
			POCSAG_Network = {"Enable"},
			DStar = {"Enable", "Module"}, 
			DStar_Network = {"Enable"}
		}
	local updated = false
	local mmdvmhost_conf = ini_load(MMDVMHOST_CONFFILE)
	local ysfgateway_conf = ini_load(YSFGATEWAY_CONFFILE)
	local p25gateway_conf = ini_load(P25GATEWAY_CONFFILE)
	local nxdngateway_conf = ini_load(NXDNGATEWAY_CONFFILE)

	-- initialize /etc/config/mmdvm
	-- mmdvmhost
	local uci_mtime = fs.stat(UCI_CONFFILE, "mtime")

	local mmdvmhost_conf_mtime = getmetatable(mmdvmhost_conf).__inifile.mtime
	local ysfgateway_conf_mtime = getmetatable(ysfgateway_conf).__inifile.mtime
	local p25gateway_conf_mtime = getmetatable(p25gateway_conf).__inifile.mtime
	local nxdngateway_conf_mtime = getmetatable(nxdngateway_conf).__inifile.mtime

	for section, options in pairs(mmdvmhost_conf_setions_needed) do
		local sename = (section:gsub("_", " ")):gsub("DStar", "D-Star")
		if mmdvmhost_conf[sename] then
			for _, option in ipairs(options) do
				if not muci:get("mmdvm", section, option) or mmdvmhost_conf_mtime > uci_mtime then
					local o = {[option] = mmdvmhost_conf[sename][option]}
					muci:section("mmdvm", "mmdvmhost", section, o)
					log(("init %s/mmdvmhost/%s/%s"):format(UCI_CONFFILE, section, json.stringify(o)))
					updated = true
				end
			end
		end
	end
	--
	-- ysfgateway
	local sename = "Network"
	local section = "YSFG_Network"
	local options = {"Startup", "InactivityTimeout", "Revert"}
	for _, option in ipairs(options) do
		if not muci:get("mmdvm", section, option) or ysfgateway_conf_mtime > uci_mtime then
			local o = {[option] = ysfgateway_conf[sename][option]}
			muci:section("mmdvm", "ysfgateway", section, o)
			log(("init %s/ysfgateway/%s/%s"):format(UCI_CONFFILE, section, json.stringify(o)))
			updated = true
		end
	end
	--
	-- p25gateway
	local sename = "Network"
	local section = "P25G_Network"
	local options = {"Startup", "InactivityTimeout", "Revert"}
	for _, option in ipairs(options) do
		if not muci:get("mmdvm", section, option) or p25gateway_conf_mtime > uci_mtime then
			local o = {[option] = p25gateway_conf[sename][option]}
			muci:section("mmdvm", "p25gateway", section, o)
			log(("init %s/p25gateway/%s/%s"):format(UCI_CONFFILE, section, json.stringify(o)))
			updated = true
		end
	end
	--
	-- nxdngateway
	local sename = "Network"
	local section = "NXDNG_Network"
	local options = {"Startup", "InactivityTimeout", "Revert"}
	for _, option in ipairs(options) do
		if not muci:get("mmdvm", section, option) or nxdngateway_conf_mtime > uci_mtime then
			local o = {[option] = nxdngateway_conf[sename][option]}
			muci:section("mmdvm", "nxdngateway", section, o)
			log(("init %s/nxdngateway/%s/%s"):format(UCI_CONFFILE, section, json.stringify(o)))
			updated = true
		end
	end

	-- dapnetgateway
	if file_exists(DAPNETGATEWAY_CONFFILE) and file_exists("/etc/init.d/dapnetgateway") then
		local dapnetgateway_conf = ini_load(DAPNETGATEWAY_CONFFILE)
		local dapnetgateway_conf_mtime = getmetatable(dapnetgateway_conf).__inifile.mtime
		local sections = {
			DAPNET_General = {section="General", options={"Callsign"}},
			DAPNET_DAPNET = {section="DAPNET", options={"Address", "AuthKey"}},
		}
		for k, v in pairs(sections) do
			for _, option in ipairs(v.options) do
				if not muci:get("mmdvm", k, option) or dapnetgateway_conf_mtime > uci_mtime then
					local o = {[option] = dapnetgateway_conf[v.section][option]}
					muci:section("mmdvm", "dapnetgateway", k, o)
					log(("init %s/dapnetgateway/%s/%s"):format(UCI_CONFFILE, k, json.stringify(o)))
					updated = true
				end
			end
		end
	end

	-- ircddbgateway
	if file_exists(IRCDDBGATEWAY_CONFFILE) and file_exists("/etc/init.d/ircddbgateway") then
		local ircddbgateway_conf = ini_load(IRCDDBGATEWAY_CONFFILE)
		local ircddbgateway_conf_mtime = getmetatable(ircddbgateway_conf).__inifile.mtime
		local sename = "default"
		local section = "ircddbgateway"
		local options = {"gatewayCallsign", "repeaterCall1", "reflector1", "ircddbUsername", "dplusLogin", "aprsHostname"}
		for _, option in ipairs(options) do
			if not muci:get("mmdvm", section, option) or ircddbgateway_conf_mtime > uci_mtime then
				local o = {[option] = ircddbgateway_conf[sename][option]}
				muci:section("mmdvm", "dstar", section, o)
				log(("init %s/ircddbgateway/%s/%s"):format(UCI_CONFFILE, section, json.stringify(o)))
				updated = true
			end
		end
	end
	
	if updated then
		muci:save("mmdvm")
		muci:commit("mmdvm")
	end	
end

--- Uci to ini synchornize
--@param changes as [["set","Info","Latitude","22.1"],["set","Info","Longitude","114.3"],["set","Modem","RXOffset","100"],["set","Info","Latitude","22.10"],["set","Info","Longitude","114.30"],["set","P25G_Network","InactivityTimeout","15"]]
function uci2ini(changes)
	local mmdvmhost_changed = false

	for _, change in ipairs(changes) do
		local action = change[1]
		local section = (change[2]:gsub("_", " ")):gsub("DStar", "D-Star")
		local option = change[3]
		local value = change[4]

		if action == "set" then
			if section:find("YSFG ") then
				local s = section:sub(6)
				local ysfgateway_conf = ini_load(YSFGATEWAY_CONFFILE)
				if ysfgateway_conf[s] and ysfgateway_conf[s][option] then
					ysfgateway_conf[s][option] = value
					ini_save(YSFGATEWAY_CONFFILE, ysfgateway_conf)
					log("YSFGateway.ini update - " .. json.stringify(change))
				end
			elseif section:find("P25G ") then
				local s = section:sub(6)
				local p25gateway_conf = ini_load(P25GATEWAY_CONFFILE)
				if p25gateway_conf[s] and p25gateway_conf[s][option] then
					p25gateway_conf[s][option] = value
					ini_save(P25GATEWAY_CONFFILE, p25gateway_conf)
					log("P25Gateway.ini update - " .. json.stringify(change))
				end
			elseif section:find("NXDNG ") then
				local s = section:sub(7)
				local nxdngateway_conf = ini_load(NXDNGATEWAY_CONFFILE)
				if nxdngateway_conf[s] and nxdngateway_conf[s][option] then
					nxdngateway_conf[s][option] = value
					ini_save(NXDNGATEWAY_CONFFILE, nxdngateway_conf)
					log("NXDNGateway.ini update - " .. json.stringify(change))
				end
			elseif section:find("DAPNET ") and file_exists(DAPNETGATEWAY_CONFFILE) and file_exists("/etc/init.d/dapnetgateway") then
				local s = section:sub(8)
				local dapnetgateway_conf = ini_load(DAPNETGATEWAY_CONFFILE)
				if dapnetgateway_conf[s] and dapnetgateway_conf[s][option] then
					dapnetgateway_conf[s][option] = value
					ini_save(DAPNETGATEWAY_CONFFILE, dapnetgateway_conf)
					log("DAPNETGateway.ini update - " .. json.stringify(change))
				end
			elseif section == "ircddbgateway" then
				local ircddbgateway_conf = ini_load(IRCDDBGATEWAY_CONFFILE)
				if ircddbgateway_conf["default"][option] then
					ircddbgateway_conf["default"][option] = value
					ini_save(IRCDDBGATEWAY_CONFFILE, ircddbgateway_conf)
					log("ircddbgateway update - " .. json.stringify(change))
				end
			else
				local mmdvmhost_conf = ini_load(MMDVMHOST_CONFFILE)
				if mmdvmhost_conf[section] and mmdvmhost_conf[section][option] then
					mmdvmhost_conf[section][option] = value
					ini_save(MMDVMHOST_CONFFILE, mmdvmhost_conf)
					log("MMDVM.ini update - " .. json.stringify(change))
				end
				mmdvmhost_changed = true
			end
		end
	end
	log(json.stringify(changes))
	return mmdvmhost_changed
end

--- String to time
--@param strtime time string in yyyy-mm-dd HH:MM:ss
function s2t(strtime)
    local year = string.sub(strtime, 1, 4)
    local month = string.sub(strtime, 6, 7)
    local day = string.sub(strtime, 9, 10)
    local hour = string.sub(strtime, 12, 13)
    local minute = string.sub(strtime, 15, 16)
	local second = string.sub(strtime, 18, 19)

	return os.time({day=day, month=month, year=year, hour=hour, min=minute, sec=second})
end

function file_exists(fname)
	-- return fs.stat(fname, 'type') == 'reg'
	return fs.access(fname)
end

function get_bm_list()
	local hostfile = "/etc/mmdvm/BMMasters.txt"
	local file = assert(io.open(hostfile, 'r'), 'Error loading file : ' .. hostfile)
	local data = {}
	for line in file:lines() do
		local tokens = line:split(",")
		table.insert(data, {tokens[1], tokens[2], tokens[4]})
	end

	return data
end

function get_ysf_list()
	local hostfile = "/etc/mmdvm/YSFHosts.txt"
	local file = assert(io.open(hostfile, 'r'), 'Error loading file : ' .. hostfile)
	local data = {}
	for line in file:lines() do
		local tokens = line:split(";")
		table.insert(data, {tokens[1], tokens[2]})
	end

	return data
end

local function _get_p25_nxdn_list(hostfile)
	local file = assert(io.open(hostfile, 'r'), 'Error loading file : ' .. hostfile)
	local data = {}
	for line in file:lines() do
		if line:trim() ~= "" and line:byte(1) ~= 35 then -- the # char
			local tokens = line:split("%s+", nil, true)
			table.insert(data, {tokens[1], tokens[2]})
		end
	end

	return data
end

function get_p25_list()
	local hostfile = "/etc/mmdvm/P25Hosts.txt"
	local hostfile_private = "/etc/mmdvm/P25Hosts_private.txt"

	local data = _get_p25_nxdn_list(hostfile)
	for _, d in ipairs(_get_p25_nxdn_list(hostfile_private)) do
		table.insert(data, {d[1], d[2] .. " - private"})
	end

	return data
end

function get_nxdn_list()
	local hostfile = "/etc/mmdvm/NXDNHosts.txt"
	local hostfile_private = "/etc/mmdvm/NXDNHosts_private.txt"

	local data = _get_p25_nxdn_list(hostfile)
	for _, d in ipairs(_get_p25_nxdn_list(hostfile_private)) do
		table.insert(data, {d[1], d[2] .. " - private"})
	end

	return data
end

function log(msg)
	msg = ("mmdvm: %s"):format(msg)
	util.ubus("log", "write", {event = msg})
end


-- logtxt = [==[
-- 	M: 2016-04-29 00:15:00.013 D-Star, received network header from DG9VH   /ZEIT to CQCQCQ   via DCS002 S
-- 	M: 2016-04-29 19:43:21.839 DMR Slot 2, received network voice header from DL1ESZ to TG 9
-- 	M: 2016-04-30 14:57:43.072 DMR Slot 2, received RF voice header from DG9VH to 5000
-- 	M: 2017-12-06 19:20:14.445 DMR Slot 2, received RF end of voice transmission, 1.8 seconds, BER: 3.9%
-- 	M: 2017-12-06 19:22:06.038 DMR Slot 2, RF voice transmission lost, 1.1 seconds, BER: 6.5%
-- 	M: 2016-04-30 14:57:43.072 DMR Slot 2, received RF CSBK Preamble CSBK (1 to follow) from M1ABC to TG 1
-- 	M: 2016-04-30 14:57:43.072 DMR Slot 2, received network Data Preamble VSBK (11 to follow) from 123456 to TG 123456
-- 	M: 2017-12-04 15:56:48.305 DMR Talker Alias (Data Format 1, Received 24/24 char): 'Hide the bottle from Ont'
-- 	M: 2017-12-04 15:56:48.306 0000:  07 00 20 4F 6E 74 00 00 00                         *.. Ont...*
-- 	M: 2017-12-04 15:56:48.305 DMR Slot 2, Embedded Talker Alias Block 3
-- 	M: 2017-04-18 08:00:41.977 P25, received RF transmission from MW0MWZ to TG 10200
-- 	M: 2017-04-18 08:00:42.131 Debug: P25RX: pos/neg/centre/threshold 106 -105 0 106
-- 	M: 2017-04-18 08:00:42.135 Debug: P25RX: sync found in Ldu pos/centre/threshold 3986 9 104
-- 	M: 2017-04-18 08:00:42.312 Debug: P25RX: pos/neg/centre/threshold 267 -222 22 245
-- 	M: 2017-04-18 08:00:42.316 Debug: P25RX: sync found in Ldu pos/centre/threshold 3986 10 112
-- 	M: 2017-04-18 08:00:42.337 P25, received RF end of transmission, 0.4 seconds, BER: 0.0%
-- 	M: 2017-04-18 08:00:43.728 P25, received network transmission from 10999 to TG 10200
-- 	M: 2017-04-18 08:00:45.172 P25, network end of transmission, 1.8 seconds, 0% packet loss
-- 	M: 2017-07-08 15:16:14.571 YSF, received RF data from 2E0EHH     to ALL
-- 	M: 2017-07-08 15:16:19.551 YSF, received RF end of transmission, 5.1 seconds, BER: 3.8%
-- 	M: 2017-07-08 15:16:21.711 YSF, received network data from G0NEF      to ALL        at MB6IBK
-- 	M: 2017-07-08 15:16:30.994 YSF, network watchdog has expired, 5.0 seconds, 0% packet loss, BER: 0.0%
-- 	M: 2017-04-18 08:00:41.977 NXDN, received RF transmission from MW0MWZ to TG 65000
-- 	M: 2017-04-18 08:00:42.131 Debug: NXDNRX: pos/neg/centre/threshold 106 -105 0 106
-- 	M: 2017-04-18 08:00:42.135 Debug: NXDNRX: sync found in Ldu pos/centre/threshold 3986 9 104
-- 	M: 2017-04-18 08:00:42.312 Debug: NXDNRX: pos/neg/centre/threshold 267 -222 22 245
-- 	M: 2017-04-18 08:00:42.316 Debug: NXDNRX: sync found in Ldu pos/centre/threshold 3986 10 112
-- 	M: 2017-04-18 08:00:42.337 NXDN, received RF end of transmission, 0.4 seconds, BER: 0.0%
-- 	M: 2017-04-18 08:00:43.728 NXDN, received network transmission from 10999 to TG 10
-- 	M: 2017-04-18 08:00:45.172 NXDN, network end of transmission, 1.8 seconds, 0% packet loss
-- 	M: 2018-07-13 10:35:18.411 POCSAG, transmitted 1 frame(s) of data from 1 message(s)
-- 	M: 2019-05-15 17:52:43.878 MMDVMHost-20190131 is running
-- 	I: 2019-05-15 17:52:43.866 Started the NXDN Id lookup reload thread
-- 	M: 2019-05-15 17:52:53.914 DMR, Logged into the master successfully
-- 	M: 2019-05-15 17:53:06.908 Downlink Activate received from BI7KJP
-- 	M: 2019-05-15 17:53:07.298 DMR Slot 1, received RF voice header from BI7KJP to TG 46073
-- 	M: 2019-05-15 17:53:08.623 DMR Slot 1, RF voice transmission lost, 1.1 seconds, BER: 5.1%
-- 	M: 2019-05-15 17:55:29.729 Downlink Activate received from BI7KJP
-- 	M: 2019-05-15 17:55:30.083 DMR Slot 1, received RF voice header from BI7KJP to TG 46073
-- 	M: 2019-05-15 17:55:31.341 DMR Slot 1, received RF end of voice transmission, 1.1 seconds, BER: 1.1%
-- M: 2019-06-01 11:40:11.358 POCSAG, transmitted 1 frame(s) of data from 1 message(s)
-- M: 2019-06-01 11:40:11.398 POCSAG, transmitted 1 frame(s) of data from 1 message(s)
-- M: 2019-06-01 11:40:11.433 POCSAG, transmitted 1 frame(s) of data from 1 message(s)
-- M: 2019-06-01 11:40:11.468 POCSAG, transmitted 1 frame(s) of data from 1 message(s)
-- 	]==]
-- 		lines = logtxt:split("\n")
-- 		table.sort(lines, function(a,b) return a>b end)
-- 	return lines
function get_mmdvm_log()
	local logtxt = ""
	local lines = {}
	local logfile = "/var/log/mmdvm/MMDVM-%s.log" % {os.date("%Y-%m-%d")}
	
	if file_exists(logfile) then
		logtxt = util.trim(util.exec("tail -n250 %s | egrep -h \"from|end|watchdog|lost\"" % {logfile}))
		lines = logtxt:split("\n")
	end

	if #lines < 20 then
		logfile = "/var/log/mmdvm/MMDVM-%s.log" % {os.date("%Y-%m-%d", os.time()-24*60*60)}
		if file_exists(logfile) then
			logtxt = logtxt .. "\n" .. util.trim(util.exec("tail -n250 %s | egrep -h \"from|end|watchdog|lost\"" % {logfile}))
			lines = logtxt:split("\n")
		end
	end

	table.sort(lines, function(a,b) return a>b end)

	return lines
end


-- local logtxt = [==[D: 2019-04-14 20:50:01.099 Queueing message to 0000000, type 6, func Alphanumeric: "bd7mqb"
-- D: 2019-04-14 20:50:01.099 Messages in Queue 0009
-- D: 2019-04-14 20:50:08.007 Rejecting message to 0002504, type 5, func Numeric: "124800   140419"
-- D: 2019-04-14 20:50:08.018 Rejecting message to 0000200, type 6, func Alphanumeric: "XTIME=1248140419XTIME=1248140419"
-- M: 2019-04-14 20:50:08.029 Sending message in slot 4 to 0000216, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414124800"
-- D: 2019-04-14 20:50:08.040 Rejecting message to 0000208, type 6, func Alphanumeric: "XTIME=1449140419XTIME=1449140419"
-- M: 2019-04-14 20:50:08.051 Sending message in slot 4 to 0000224, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414144900"
-- M: 2019-04-14 20:50:08.062 Sending message in slot 4 to 0002504, type 5, func Numeric: "125000   140419"
-- M: 2019-04-14 20:50:08.073 Sending message in slot 4 to 0000200, type 6, func Alphanumeric: "XTIME=1250140419XTIME=1250140419"
-- M: 2019-04-14 20:50:08.084 Sending message in slot 4 to 0000216, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414125000"
-- M: 2019-04-14 20:50:08.095 Sending message in slot 4 to 0000000, type 6, func Alphanumeric: "bd7mqb"
-- D: 2019-04-14 20:50:33.725 Queueing message to 0101211, type 6, func Alphanumeric: "DL1HQN: Dies ist ein Test, sch|n das du wieder online bist hu hu :)"
-- D: 2019-04-14 20:50:33.725 Messages in Queue 0001
-- M: 2019-04-14 20:50:33.726 Sending message in slot 8 to 0101211, type 6, func Alphanumeric: "DL1HQN: Dies ist ein Test, sch|n das du wieder online bist hu hu :)"
-- D: 2019-04-14 20:50:34.031 Queueing message to 2020008, type 6, func Alphanumeric: "DL1HQN: Dies ist ein Test, sch|n das du wieder online bist hu hu :)"
-- D: 2019-04-14 20:50:34.031 Messages in Queue 0001
-- M: 2019-04-14 20:50:34.032 Sending message in slot 8 to 2020008, type 6, func Alphanumeric: "DL1HQN: Dies ist ein Test, sch|n das du wieder online bist hu hu :)"
-- D: 2019-04-14 20:50:34.336 Queueing message to 0103091, type 6, func Alphanumeric: "DL1HQN: Dies ist ein Test, sch|n das du wieder online bist hu hu :)"
-- D: 2019-04-14 20:50:34.337 Messages in Queue 0001
-- M: 2019-04-14 20:50:34.337 Sending message in slot 8 to 0103091, type 6, func Alphanumeric: "DL1HQN: Dies ist ein Test, sch|n das du wieder online bist hu hu :)"
-- D: 2019-04-14 20:51:00.186 Queueing message to 0000208, type 6, func Alphanumeric: "XTIME=1451140419XTIME=1451140419"
-- D: 2019-04-14 20:51:00.186 Messages in Queue 0001
-- M: 2019-04-14 20:51:00.187 Sending message in slot 12 to 0000208, type 6, func Alphanumeric: "XTIME=1451140419XTIME=1451140419"
-- D: 2019-04-14 20:51:00.491 Queueing message to 0000224, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414145100"
-- D: 2019-04-14 20:51:00.492 Messages in Queue 0001
-- M: 2019-04-14 20:51:00.493 Sending message in slot 12 to 0000224, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414145100"
-- D: 2019-04-14 20:52:00.181 Queueing message to 0002504, type 5, func Numeric: "125200   140419"
-- D: 2019-04-14 20:52:00.181 Messages in Queue 0001
-- D: 2019-04-14 20:52:01.000 Queueing message to 0000200, type 6, func Alphanumeric: "XTIME=1252140419XTIME=1252140419"
-- D: 2019-04-14 20:52:01.001 Messages in Queue 0002
-- D: 2019-04-14 20:52:02.859 Queueing message to 0000216, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414125200"
-- D: 2019-04-14 20:52:02.860 Messages in Queue 0003
-- D: 2019-04-14 20:52:16.001 Rejecting message to 0002504, type 5, func Numeric: "125200   140419"
-- D: 2019-04-14 20:52:16.012 Rejecting message to 0000200, type 6, func Alphanumeric: "XTIME=1252140419XTIME=1252140419"
-- M: 2019-04-14 20:52:16.023 Sending message in slot 8 to 0000216, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414125200"
-- D: 2019-04-14 20:53:00.186 Queueing message to 0000208, type 6, func Alphanumeric: "XTIME=1453140419XTIME=1453140419"
-- D: 2019-04-14 20:53:00.186 Messages in Queue 0001
-- D: 2019-04-14 20:53:00.491 Queueing message to 0000224, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414145300"
-- D: 2019-04-14 20:53:00.491 Messages in Queue 0002
-- M: 2019-04-14 20:53:07.207 Sending message in slot 0 to 0000208, type 6, func Alphanumeric: "XTIME=1453140419XTIME=1453140419"
-- M: 2019-04-14 20:53:07.218 Sending message in slot 0 to 0000224, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414145300"
-- D: 2019-04-14 20:54:00.187 Queueing message to 0002504, type 5, func Numeric: "125400   140419"
-- D: 2019-04-14 20:54:00.187 Messages in Queue 0001
-- M: 2019-04-14 20:54:00.188 Sending message in slot 8 to 0002504, type 5, func Numeric: "125400   140419"
-- D: 2019-04-14 20:54:00.492 Queueing message to 0000200, type 6, func Alphanumeric: "XTIME=1254140419XTIME=1254140419"
-- D: 2019-04-14 20:54:00.493 Messages in Queue 0001
-- M: 2019-04-14 20:54:00.493 Sending message in slot 8 to 0000200, type 6, func Alphanumeric: "XTIME=1254140419XTIME=1254140419"
-- D: 2019-04-14 20:54:00.798 Queueing message to 0000216, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414125400"
-- D: 2019-04-14 20:54:00.799 Messages in Queue 0001
-- M: 2019-04-14 20:54:00.799 Sending message in slot 8 to 0000216, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414125400"
-- D: 2019-04-14 20:55:00.710 Queueing message to 0000208, type 6, func Alphanumeric: "XTIME=1455140419XTIME=1455140419"
-- D: 2019-04-14 20:55:00.711 Messages in Queue 0001
-- D: 2019-04-14 20:55:01.552 Queueing message to 0000224, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414145500"
-- D: 2019-04-14 20:55:01.553 Messages in Queue 0002
-- D: 2019-04-14 20:55:16.189 Rejecting message to 0000208, type 6, func Alphanumeric: "XTIME=1455140419XTIME=1455140419"
-- M: 2019-04-14 20:55:16.200 Sending message in slot 4 to 0000224, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414145500"
-- D: 2019-04-14 20:56:00.181 Queueing message to 0002504, type 5, func Numeric: "125600   140419"
-- D: 2019-04-14 20:56:00.182 Messages in Queue 0001
-- D: 2019-04-14 20:56:00.487 Queueing message to 0000200, type 6, func Alphanumeric: "XTIME=1256140419XTIME=1256140419"
-- D: 2019-04-14 20:56:00.488 Messages in Queue 0002
-- D: 2019-04-14 20:56:00.792 Queueing message to 0000216, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414125600"
-- D: 2019-04-14 20:56:00.793 Messages in Queue 0003
-- M: 2019-04-14 20:56:06.400 Sending message in slot 12 to 0002504, type 5, func Numeric: "125600   140419"
-- M: 2019-04-14 20:56:06.412 Sending message in slot 12 to 0000200, type 6, func Alphanumeric: "XTIME=1256140419XTIME=1256140419"
-- M: 2019-04-14 20:56:06.423 Sending message in slot 12 to 0000216, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414125600"
-- D: 2019-04-14 20:57:00.183 Queueing message to 0000208, type 6, func Alphanumeric: "XTIME=1457140419XTIME=1457140419"
-- D: 2019-04-14 20:57:00.184 Messages in Queue 0001
-- M: 2019-04-14 20:57:00.184 Sending message in slot 4 to 0000208, type 6, func Alphanumeric: "XTIME=1457140419XTIME=1457140419"
-- D: 2019-04-14 20:57:00.489 Queueing message to 0000224, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414145700"
-- D: 2019-04-14 20:57:00.490 Messages in Queue 0001
-- M: 2019-04-14 20:57:00.490 Sending message in slot 4 to 0000224, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414145700"
-- D: 2019-04-14 20:58:00.192 Queueing message to 0002504, type 5, func Numeric: "125800   140419"
-- D: 2019-04-14 20:58:00.192 Messages in Queue 0001
-- D: 2019-04-14 20:58:00.496 Queueing message to 0000200, type 6, func Alphanumeric: "XTIME=1258140419XTIME=1258140419"
-- D: 2019-04-14 20:58:00.497 Messages in Queue 0002
-- D: 2019-04-14 20:58:00.791 Queueing message to 0000216, type 6, func Alphanumeric: "YYYYMMDDHHMMSS190414125800"
-- 	]==]
-- 	lines = logtxt:split("\n")
function get_dapnet_log()
	local logtxt = ""
	local lines = {}
	local logfile = "/var/log/mmdvm/DAPNETGateway-%s.log" % {os.date("%Y-%m-%d")}
	
	if file_exists(logfile) then
		logtxt = util.trim(util.exec("tail -n250 %s | egrep -h \"Sending message\"" % {logfile}))
		lines = logtxt:split("\n")
	end

	if #lines < 20 then
		logfile = "/var/log/mmdvm/DAPNETGateway-%s.log" % {os.date("%Y-%m-%d", os.time()-24*60*60)}
		if file_exists(logfile) then
			logtxt = logtxt .. "\n" .. util.trim(util.exec("tail -n250 %s | egrep -h \"Sending message\"" % {logfile}))
			lines = logtxt:split("\n")
		end
	end

	table.sort(lines, function(a,b) return a>b end)

	return lines
end

local function get_hearlist(loglines)
	local headlist = {}
	local duration, loss, ber, rssi
	-- local ts1duration, ts1loss, ts1ber, ts1rssi
	-- local ts2duration, ts2loss, ts2ber, ts2rssi
	-- local ysfduration, ysfloss, ysfber, ysfrssi
	-- local p25duration, p25loss, p25ber, p25rssi

	for i = 1, #loglines do
		local logline = loglines[i]
		-- remoing invaild lines
		repeat
			if string.find(logline, "BS_Dwn_Act") or
				string.find(logline, "invalid access") or
				string.find(logline, "received RF header for wrong repeater") or
				string.find(logline, "Error returned") or
				string.find(logline, "unable to decode the network CSBK") or
				string.find(logline, "overflow in the DMR slot RF queue") or
				string.find(logline, "non repeater RF header received") or
				string.find(logline, "Embedded Talker Alias") or 
				string.find(logline, "DMR Talker Alias") or
				string.find(logline, "CSBK Preamble") or
				string.find(logline, "Preamble CSBK") or
				string.find(logline, "Preamble VSBK") or
				string.find(logline, "Downlink Activate received") or
				string.find(logline, "Received a NAK") or
				string.find(logline, "0000")
			then
				break
			end

			local mode = string.sub(logline, 28, (string.find(logline, ",") or 0)-1)

			if string.find(logline, "end of") 
				or string.find(logline, "watchdog has expired")
				or string.find(logline, "ended RF data")
				or string.find(logline, "ended network")
				or string.find(logline, "RF user has timed out")
				or string.find(logline, "transmission lost")
				or string.find(logline, "D-Star")
				or string.find(logline, "POCSAG")
			then
				local linetokens = logline:split(", ")
				local count_tokens = (linetokens and #linetokens) or 0

				if string.find(logline, "RF user has timed out") then
					duration = "-1"
					ber = "-1"
				else
					if count_tokens >= 3 then
						duration = string.trim(string.sub(linetokens[3], 1, string.find(linetokens[3], " ")))
					end
					if count_tokens >= 4 then
						loss = linetokens[4]
					end
				end

				-- if RF-Packet, no LOSS would be reported, so BER is in LOSS position
				if string.find(loss or "", "BER") == 1 then
					ber = string.trim(string.sub(loss, 6, 8))

					loss = "0"
					-- TODO: RSSI
				else
					loss = string.trim(string.sub(loss or "", 1, -14))
					if count_tokens >= 5 then
						ber = string.trim(string.sub(linetokens[5] or "", 6, -2))
						
					end
				end

			end

			local timestamp = string.sub(logline, 4, 22)
			local callsign, target
			local source = "RF"

			if mode ~= 'POCSAG' then
				if string.find(logline, "from") and string.find(logline, "to") then
					callsign = string.gsub(string.trim(string.sub(logline, string.find(logline, "from")+5, string.find(logline, "to") - 2)), " ", "")
					target = string.sub(logline, string.find(logline, "to") + 3)
					target = string.gsub(string.trim(string.sub(target, 0, string.find(target, ","))), ",", "")
				end
				if string.find(logline, "network") then
					source = "Net"
				end
			end
			-- if mode then
				-- switch selection of mode
				local switch = {
					["DMR Slot 1"] = function()
						if string.find(logline, "ended RF data") or string.find(logline, "ended network") then
							duration = "SMS"
						end
					end,
					["DMR Slot 2"] = function()
						if string.find(logline, "ended RF data") or string.find(logline, "ended network") then
							duration = "SMS"
						end
					end,
					["YSF"] = function()
						if target and target:find('at') then
							target = string.trim(string.sub(target, 14))
						end
					end,
					["P25"] = function()
						if source == "Net" then
							if target == "TG 10" then
								callsign = "PARROT"
							end
							if callsign == "10999" then
								callsign = "MMDVM"
							end
						end
					end,
					["NXDN"] = function()
						if source == "Net" then
							if target == "TG 10" then
								callsign = "PARROT"
							end
						end
					end,
					["D-Star"] = function()
						
					end,
					["POCSAG"] = function()
						callsign = 'DAPNET'
						source = "Net"
						target = 'ALL'
						duration = '0.0'
						loss = '0'
						ber = '0.0'
					end,
				}
				local f = switch[mode]
				if(f) then f() end
				-- end of switch
			-- end
			
			-- Callsign or ID should be less than 11 chars long, otherwise it could be errorneous
			if callsign and #callsign:trim() <= 11 then
				table.insert(headlist, 
					{
						timestamp = timestamp, 
						mode = mode, 
						callsign = callsign, 
						target = target, 
						source = source,
						duration = duration,
						loss = tonumber(loss) or 0,
						ber = tonumber(ber) or 0,
						rssi = rssi
					}
				)
			end

		until true -- end repeat
	end -- end loop

	-- table.insert(headlist, 
	-- 	{
	-- 		timestamp = "timestamp", 
	-- 		mode = "mode", 
	-- 		callsign = "callsign", 
	-- 		target = "target", 
	-- 		source = "RF",
	-- 		duration = "duration",
	-- 		loss = tonumber(loss) or 0,
	-- 		ber = tonumber(ber) or 0,
	-- 		rssi = rssi
	-- 	}
	-- )
	return headlist
end

function get_lastheard()
	local lh = {}
	local calls = {}
	local loglines = get_mmdvm_log()
	local headlist = get_hearlist(loglines)

	for i = 1, #headlist, 1 do
		local key = headlist[i].callsign .. "@" .. headlist[i].mode
		
		if calls[key] == nil then
			calls[key] = true
			table.insert(lh, headlist[i])
		end

	end

	return lh
end

function get_last_pocsag()
	local logs = {}
	local loglines = get_dapnet_log()

	for _, logline in ipairs(loglines) do
		local linetokens = logline:split(", ")
		local count_tokens = (linetokens and #linetokens) or 0
		if count_tokens < 3 then break end
		local timestamp, timeslot, ric, msg
		
		timestamp = logline:sub(4, 22)

		if count_tokens >= 3 then
			local t1 = linetokens[1]:split(" ")
			timeslot = t1[8]
			ric = t1[10]
			local t2 = logline:split('"')
			msg = t2[2]
		end

		table.insert(logs, {
			timestamp = timestamp,
			timeslot = timeslot,
			target = ric,
			message = msg
		})
		if #logs > 20 then break end
	end

	return logs
end