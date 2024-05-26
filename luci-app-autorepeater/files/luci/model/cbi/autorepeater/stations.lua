local NX   = require "nixio"
local NXFS = require "nixio.fs"
--local SYS  = require "luci.sys"
--local UTIL = require "luci.util"
local DISP = require "luci.dispatcher"
--local WADM = require "luci.tools.webadmin"
local DTYP = require "luci.cbi.datatypes"
local ATRP = require "luci.tools.autorepeater"		-- autorepeater multiused functions

-- takeover arguments -- #######################################################
local section = arg[1]or""
local isec = arg[2]or""
if isec == "wan" then
	isec = ""
end
if isec ~="" then
	isec = "-" .. isec
end
-- html constants -- ###########################################################
local font_red	= "<font color='red'>"
local font_off	= "</font>"
local bold_on	= "<strong>"
local bold_off	= "</strong>"

-- cbi-map definition -- #######################################################
m = Map("autorepeater")

-- first need to close <a> from cbi map template our <a> closed by template
m.title = [[</a><a href="]] .. DISP.build_url("admin", "services", "autorepeater") .. [[">]] ..
		translate("Auto Repeater") .. [[</a>]]

m.description = translate("Auto Repeater helps you turn your router as a repeater, " ..
			"join a wireless station by scan station ssid or bssid first.")

m.redirect = DISP.build_url("admin", "services", "autorepeater", "autorepeater-overview", isec)

m.on_after_commit = function(self)
	if self.changed then	-- changes ?
		local pid = ATRP.get_pid(section)
		if pid > 0 then	-- running ?
			local tmp = NX.kill(pid, 1)	-- send SIGHUP
		end
	end
end

-- read application settings -- ################################################
-- date format; if not set use ISO format
date_format = m.uci:get(m.config, "global", "date_format") or "%F %R"
-- log directory
log_dir = m.uci:get(m.config, "global", "log_dir") or "/var/log/autorepeater"

-- cbi-section definition -- ###################################################
ns = m:section( NamedSection, section, "wifi-station" .. isec,
	translate("Details for") .. ([[: <strong>%s</strong>]] % section),
	translate("Configure here the details for selected broadcating station.") )
--ns.instance = section	-- arg [1]

-- enabled  -- #################################################################
en = ns:option(Flag, "enabled",
	translate("Enabled"),
	translate("If this station is disabled it could not be connected automatically." .. "<br />" ..
		"Neither from LuCI interface nor from console") )
en.orientation = "horizontal"
function en.parse(self, section)
	ATRP.flag_parse(self, section)
end

-- macchanger -- ###############################################################
local mac	= ns:option(Value, "macaddr")
mac.title	= translate("MAC Changer")
mac.description	= translate("MAC address for faking, macchanger bin needed.")
mac:value("", translate("Disabled"))
mac:value("auto", translate("Randomly"))
mac.rmempty	= true
mac.default	= ""
function mac.validate(self, value)
	if mac:formvalue(section) ~= "auto" then	-- checking mac
		if DTYP.macaddr(value) then return value end
		return nil, "Faking MAC Address Checking Error!"
	else
		return value	-- supress validate error
	end
end


-- is_mac (NEW)  -- ##########################################################
dev_t = ns:option(ListValue, "is_mac",
	translate("Scanning Type"))
--	translate("Defines which ssid or bssid station to connecting to") )
--dev_t.template = "autorepeater/detail_lvalue"
dev_t.orientation = "horizontal"
dev_t.widget  = "radio"
dev_t.default = "0"
dev_t:value("0", translate("SSID") )
dev_t:value("1", translate("BSSID") )
function dev_t.validate(self, value)
	if (value == "1") then
		return "1"
	else
		return "0"
	end
end
function dev_t.write(self, section, value)
	if value == "0" then	-- force rmempty
		return self.map:del(section, self.option)
	else
		return self.map:set(section, self.option, value)
	end
end

-- dev_str - mathing_string -- ######################################################
dev_s = ns:option(Value, "dev_str",
	translate("Matching String"))
dev_s.default	= "-"

function dev_s.cfgvalue(self, section)
	local v =  ATRP.read_value(self, section, "dev_str")
	if not v or #v == 0 then
		return "-"
	else
		return v
	end
end
function dev_s.validate(self, value)
	if dev_t:formvalue(section) == "1" then	-- checking mac
		if DTYP.macaddr(value) then return value end
		return nil, "Matching MAC Address Checking Error!"
	else
		return value	-- supress validate error
	end
end

------------------- WiFI-Encryption -------------------

encr = ns:option(ListValue, "encryption", translate("Encryption"))
cipher = ns:option(ListValue, "cipher", translate("Cipher"))
cipher:value("auto", translate("Detemine by scanning"))
cipher:value("ccmp", translate("Force CCMP (AES)"))
cipher:value("tkip", translate("Force TKIP"))
cipher:value("tkip+ccmp", translate("Force TKIP and CCMP (AES)"))

function encr.cfgvalue(self, section)
	local v = tostring(ListValue.cfgvalue(self, section))
	if v == "wep" then
		return "wep-open"
	elseif v and v:match("%+") then
		return (v:gsub("%+.+$", ""))
	end
	return v
end

function encr.write(self, section, value)
	local e = tostring(encr:formvalue(section))
	local c = tostring(cipher:formvalue(section))
	if value == "wpa" or value == "wpa2"  then
		self.map.uci:delete("autorepeater", section, "key")
	end
	if e and (c == "tkip" or c == "ccmp" or c == "tkip+ccmp") then
		e = e .. "+" .. c
	end
	self.map:set(section, "encryption", e)
end

function cipher.cfgvalue(self, section)
	local v = tostring(ListValue.cfgvalue(encr, section))
	if v and v:match("%+") then
		v = v:gsub("^[^%+]+%+", "")
		if v == "aes" then v = "ccmp"
		elseif v == "tkip+aes" then v = "tkip+ccmp"
		elseif v == "aes+tkip" then v = "tkip+ccmp"
		elseif v == "ccmp+tkip" then v = "tkip+ccmp"
		end
	end
	return v
end

function cipher.write(self, section)
	return encr:write(section)
end


encr:value("none", translate("No Encryption"))
encr:value("auto", translate("Detemine by scanning"))

--if hwtype == "atheros" or hwtype == "mac80211" or hwtype == "prism2" then
	local supplicant = NXFS.access("/usr/sbin/wpa_supplicant")
	local hostapd = NXFS.access("/usr/sbin/hostapd")

	-- Probe EAP support
	local has_ap_eap  = (os.execute("hostapd -veap >/dev/null 2>/dev/null") == 0)
	local has_sta_eap = (os.execute("wpa_supplicant -veap >/dev/null 2>/dev/null") == 0)

	if hostapd and supplicant then
		encr:value("psk", "WPA-PSK")
		encr:value("psk2", "WPA2-PSK")
		encr:value("psk-mixed", "WPA-PSK/WPA2-PSK Mixed Mode")
		if has_ap_eap and has_sta_eap then
			encr:value("wpa", "WPA-EAP")
			encr:value("wpa2", "WPA2-EAP")
		end
	elseif hostapd and not supplicant then
		encr:value("psk", "WPA-PSK")
		encr:value("psk2", "WPA2-PSK")
		encr:value("psk-mixed", "WPA-PSK/WPA2-PSK Mixed Mode")
		if has_ap_eap then
			encr:value("wpa", "WPA-EAP")
			encr:value("wpa2", "WPA2-EAP")
		end
		encr.description = translate(
			"WPA-Encryption requires wpa_supplicant (for client mode) or hostapd (for AP " ..
			"and ad-hoc mode) to be installed."
		)
	elseif not hostapd and supplicant then
		encr:value("psk", "WPA-PSK")
		encr:value("psk2", "WPA2-PSK")
		encr:value("psk-mixed", "WPA-PSK/WPA2-PSK Mixed Mode")
		if has_sta_eap then
			encr:value("wpa", "WPA-EAP")
			encr:value("wpa2", "WPA2-EAP")
		end
		encr.description = translate(
			"WPA-Encryption requires wpa_supplicant to be installed."
		)
	else
		encr.description = translate(
			"WPA-Encryption requires wpa_supplicant to be installed."
		)
	end
--elseif hwtype == "broadcom" then
--	encr:value("psk", "WPA-PSK")
--	encr:value("psk2", "WPA2-PSK")
	encr:value("psk+psk2", "broadcom-WPA-PSK/WPA2-PSK Mixed Mode")
--end

wpakey = ns:option(Value, "_wpa_key", translate("Key"))
--wpakey:depends("encryption", "psk")
--wpakey:depends("encryption", "psk2")
--wpakey:depends("encryption", "psk+psk2")
--wpakey:depends("encryption", "psk-mixed")
--wpakey.datatype = "wpakey"
wpakey.rmempty = true
wpakey.password = true
wpakey.cfgvalue = function(self, section, value)
	return self.map.uci:get("autorepeater", section, "key") or ""
end
wpakey.write = function(self, section, value)
	self.map.uci:set("autorepeater", section, "key", value)
end

-------------
local apply = luci.http.formvalue("cbi.apply")
if apply then
	os.execute("/etc/init.d/autorepeater restart >/dev/null 2>&1 &")
end
--------------

return m
