m = Map("autoupdate",translate("Manually Upgrade"),translate("Manually upgrade Firmware or Script"))
s = m:section(TypedSection,"autoupdate")
s.anonymous = true

local local_version = luci.sys.exec ("autoupdate -V")
local local_script_version = luci.sys.exec ("autoupdate -v")

check_updates = s:option (Button, "_check_updates", translate("Check Updates"),translate("Please wait for the page to refresh after clicking Check Updates button"))
check_updates.inputtitle = translate ("Check Updates")
check_updates.write = function()
	luci.sys.call ("autoupdate -V Cloud > /tmp/Cloud_Version")
	luci.sys.call ("autoupdate -v Cloud > /tmp/Cloud_Script_Version")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "autoupdate", "manual"))
end

local cloud_version = luci.sys.exec ("cat /tmp/Cloud_Version 2> /dev/null")
local cloud_script_version = luci.sys.exec ("cat /tmp/Cloud_Script_Version 2> /dev/null")

upgrade_fw = s:option (Button, "_upgrade_fw", translate("Upgrade Firmware"),translate("Upgrade Normally (KEEP CONFIG)") .. "<br><br>当前固件版本: " .. local_version .. "<br>云端固件版本: " .. cloud_version)
upgrade_fw.inputtitle = translate ("Do Upgrade")
upgrade_fw.write = function()
	luci.sys.call ("autoupdate -u > /dev/null &")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "autoupdate", "log"))
end

upgrade_fw_force = s:option (Button, "_upgrade_fw_force", translate("Upgrade Firmware"),translate("Upgrade with Force Flashing (DANGEROUS)"))
upgrade_fw_force.inputtitle = translate ("Do Upgrade")
upgrade_fw_force.write = function()
	luci.sys.call ("autoupdate -u -F > /dev/null &")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "autoupdate", "log"))
end

upgrade_fw_n = s:option (Button, "_upgrade_fw_n", translate("Upgrade Firmware"),translate("Upgrade without keeping System-Config"))
upgrade_fw_n.inputtitle = translate ("Do Upgrade")
upgrade_fw_n.write = function()
	luci.sys.call ("autoupdate -u -n > /dev/null &")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "autoupdate", "log"))
end

upgrade_script = s:option (Button, "_upgrade_script", translate("Upgrade Script"),translate("Using the latest Script may solve some compatibility problems") .. "<br><br>当前脚本版本: " .. local_script_version .. "<br>云端脚本版本: " .. cloud_script_version)
upgrade_script.inputtitle = translate ("Do Upgrade")
upgrade_script.write = function()
	luci.sys.call ("autoupdate -x -P > /dev/null &")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "autoupdate", "log"))
end

return m
