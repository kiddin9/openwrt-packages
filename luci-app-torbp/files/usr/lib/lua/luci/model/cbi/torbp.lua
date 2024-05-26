-- Copyright 2018-2020 Alex D (https://gitlab.com/Nooblord/)
-- Copyright 2022 ZeroChaos (https://github.com/zerolabnet/)
-- This is free software, licensed under the GNU General Public License v3.

-- [GLOBAL VARS] --------------------------------------------------------------
local torrc = "/etc/tor/torrc"
local makeTorConfigButtonPressed = false
local torrcSampleConfig = 'User tor\n' ..
						  'HardwareAccel 1\n' ..
						  'Log notice syslog\n' ..
						  'SocksPort 0.0.0.0:9150\n' ..
						  'DataDirectory /var/lib/tor\n' ..
						  'ExcludeExitNodes {us},{ca},{cn},{hk},{jp},{kr},{tw},{ru},{ua},{by},{kz},{in},{af},{aq},{ar},{au},{bs},{bh},{bb},{bz},{bo},{bw},{br},{bn},{bf},{bi},{kh},{cm},{cv},{ky},{cf},{td},{cl},{co},{km},{cg},{cd},{ck},{cr},{ci},{cu},{dj},{dm},{do},{ec},{eg},{sv},{gq},{et},{fk},{fo},{fj},{ga},{gm},{gh},{gi},{gl},{gd},{gp},{gu},{gt},{gn},{gw},{gy},{ht},{hn},{id},{ir},{iq},{il},{jm},{jo},{ke},{ki},{kp},{kg},{lb},{ls},{lr},{ly},{mo},{mg},{mw},{my},{mv},{ml},{mt},{mh},{mq},{mr},{mu},{yt},{mx},{fm},{mn},{ms},{ma},{mz},{mm},{na},{nr},{np},{nc},{nz},{ni},{ne},{ng},{nu},{nf},{mp},{om},{pk},{pw},{ps},{pa},{pg},{py},{pe},{ph},{pr},{qa},{re},{rw},{ws},{st},{sa},{sn},{sc},{sl},{sb},{so},{as},{za},{lk},{kn},{lc},{pm},{vc},{sd},{sr},{sz},{sy},{tj},{tz},{th},{tg},{tk},{to},{tt},{tn},{tr},{tm},{tc},{tv},{ug},{ae},{uy},{vu},{vn},{vi},{wf},{ye},{zm},{zw},{??}\n' ..
						  'StrictNodes 1\n' ..
						  'UseBridges 1\n' ..
						  'ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy\n' ..
						  'Bridge '

local fontred = "<font color=\"red\">"
local fontgreen = "<font color=\"green\">"
local endfont = "</font>"
local bold = "<strong>"
local endbold = "</strong>"
local brtag ="<br />"
-------------------------------------------------------------------------------

-- [VARS INITIALIZATION] ------------------------------------------------------
-- Detect TOR
local torBinary = luci.util.exec("/usr/bin/which tor")

if torBinary ~= "" then
	local torPid = luci.util.exec("/usr/bin/pgrep tor")
	torServiceStatus = luci.util.exec("/bin/ls /etc/rc.d/S??tor 2>/dev/null")
	if torServiceStatus ~= "" then
		torServiceStatusValue = fontgreen .. translate("ENABLED on boot") .. endfont
	else
		torServiceStatusValue = fontred .. translate("NOT ENABLED on boot") .. endfont
	end
	if torPid ~= "" then
		torStatus = bold .. fontgreen .. translate("Tor is Running") .. endfont ..
		" " .. translate("with PID") .. " " .. torPid .. " " ..
		translate("and") .. " " .. torServiceStatusValue .. endbold
	else
		torStatus = bold .. fontred .. translate("Tor is not Running") .. endfont .. " " ..
		translate("and") .. " " .. torServiceStatusValue .. endbold
	end
else
	torStatus = bold .. fontred .. translate("Tor is not Installed") .. endfont .. endbold
end
-- Detect TOR END
-------------------------------------------------------------------------------

-- [SECTION INIT] -------------------------------------------------------------
m = Map("torbp")
m.pageaction = false
m.title	= translate("Tor bridges proxy")
m.description = translate("Tor with SOCKS 5 proxy with a UI for the ability to add bridges")
s = m:section(TypedSection, "torbp")
s.anonymous = true
s.addremove = false
-------------------------------------------------------------------------------

-- [TOR CONFIGURATION TAB] ----------------------------------------------------
s:tab("torConfig", translate("Tor configuration"))

torrcStatus = s:taboption("torConfig",DummyValue, "torrcStatus", " ")
torrcStatus.rawhtml = true
function torrcStatus.cfgvalue(self, section)
	return torStatus
end

if torBinary ~= "" then
	if torServiceStatus ~= "" then
		torrcButtonDisable = s:taboption("torConfig",Button,"Stop & Disable start on boot"," ")
		torrcButtonDisable.inputtitle=translate("Stop & Disable start on boot")
		torrcButtonDisable.inputstyle="remove"
		function torrcButtonDisable.write()
			luci.sys.exec("/etc/init.d/tor stop")
			luci.sys.exec("sleep 1")
			luci.sys.exec("/etc/init.d/tor disable")
			luci.sys.exec("sleep 1")
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "torbp"))
		end
	else
		torrcButtonEnable = s:taboption("torConfig",Button,translate("Start & Enable start on boot")," ")
		torrcButtonEnable.inputtitle=translate("Start & Enable start on boot")
		torrcButtonEnable.inputstyle="apply"
		function torrcButtonEnable.write()
			luci.sys.exec("/etc/init.d/tor start")
			luci.sys.exec("sleep 1")
			luci.sys.exec("/etc/init.d/tor enable")
			luci.sys.exec("sleep 1")
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "torbp"))
		end
	end

	if nixio.fs.access(torrc) then
		torrcButtonConfig = s:taboption("torConfig",Button,translate("Make me Tor config")," ",translate("Create a sample Tor config"))
		torrcButtonConfig.inputtitle=translate("Make me Tor config")
		function torrcButtonConfig.write()
			makeTorConfigButtonPressed = true
			nixio.fs.writefile(torrc, torrcSampleConfig)
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "torbp"))
		end
	end
end

if nixio.fs.access(torrc) then
	torrcConfig = s:taboption("torConfig",TextValue,"torrcConfig",translate("Edit torrc file"))
	torrcConfig.optional = true
	torrcConfig.rmempty=true
	torrcConfig.rows=19
	torrcConfig.wrap = "off"

	function torrcConfig.cfgvalue(self, section)
		if nixio.fs.access(torrc) then
			return nixio.fs.readfile(torrc)
		else
			return "No torrc file."
		end
	end

	function torrcConfig.write(self, section, value)
		if value == nil or value == '' then
		elseif nixio.fs.access(torrc) then
			value = value:gsub("\r\n?", "\n")
			local old_value = nixio.fs.readfile(torrc)
			if value ~= old_value and not makeTorConfigButtonPressed then
				nixio.fs.writefile(torrc, value)
			end
		end
	end

	torrcButtonRestart = s:taboption("torConfig",Button,"Apply & Restart Tor"," ")
	torrcButtonRestart.inputtitle=translate("Apply & Restart Tor")
	torrcButtonRestart.inputstyle="apply"
	function torrcButtonRestart.write()
		luci.sys.exec("/etc/init.d/tor restart")
		luci.sys.exec("sleep 1")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "torbp"))
	end
end
-------------------------------------------------------------------------------

-- [ LOG TAB] ----------------------------------------------------------------
s:tab("log",translate("Log"))

logsTor = s:taboption("log",TextValue,"logsTor",translate("Tor log"))
logsTor.readonly = "readonly"
logsTor.rmempty=true
logsTor.rows=30
logsTor.wrap = "on"

function logsTor.cfgvalue(self, section)
	return luci.util.exec("/sbin/logread -e Bootstrapped")
end

function logsTor.write(self, section, value)
end
-------------------------------------------------------------------------------

return m