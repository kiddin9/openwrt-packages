module("luci.model.cbi.gpsysupgrade.sysupgrade", package.seeall)
local fs = require "nixio.fs"
local sys = require "luci.sys"
local util = require "luci.util"
local i18n = require "luci.i18n"
local api = require "luci.model.cbi.gpsysupgrade.api"

function get_system_version()
	local system_version = luci.sys.exec("[ -f '/etc/openwrt_version' ] && echo -n `cat /etc/openwrt_version`")
    return system_version
end

function check_update()
		needs_update, notice, md5 = false, false, false
		remote_version = luci.sys.exec("curl -skfL https://dl.openwrt.ai/firmware/" ..model.. "/version.txt")
		updatelogs = luci.sys.exec("curl -skfL https://dl.openwrt.ai/firmware/updatelogs.txt")
		remoteformat = luci.sys.exec("date -d $(echo \"" ..remote_version.. "\" | tr '\r\n' ',' | awk -F, '{printf $1}' | awk -F. '{printf $3\"-\"$1\"-\"$2}') +%s")
		fnotice = luci.sys.exec("echo \"" ..remote_version.. "\" | tr '\r\n' ',' | awk -F, '{printf $(NF-1)}'")
		md5 = luci.sys.exec("echo \"" ..remote_version.. "\" | tr '\r\n' ',' | awk -F, '{printf $2}'")
		remote_version = luci.sys.exec("echo \"" ..remote_version.. "\" | tr '\r\n' ',' | awk -F, '{printf $1}' | awk -F. '{printf $1\".\"$2\".\"$3}'")
		if remoteformat > sysverformat then
			needs_update = true
			if currentTimeStamp > remoteformat or fnotice == "1" then
				notice = true
			end
		end
end

function to_check()
    if not board_name or board_name == "" then board_name = luci.sys.exec("echo -n \"" ..api.auto_get_board_name().. "\" | sed s/,/_/") end
	arch = nixio.uname().machine
	local boardinfo = luci.util.ubus("system", "board") or { }
	target = luci.sys.exec("echo -n \"" ..boardinfo.release.target.. "\" | sed s,/,-,")
	sysverformat = luci.sys.exec("date -d $(echo " ..get_system_version().. " | awk -F. '{printf $3\"-\"$1\"-\"$2}') +%s")
	currentTimeStamp = luci.sys.exec("expr $(date -d \"$(date '+%Y-%m-%d %H:%M:%S')\" +%s) - 172800")
	model = target.. "/" ..board_name
    if board_name == "x86_64" then
    	model = "x86_64"
    	check_update()
    	if fs.access("/sys/firmware/efi") then
    		download_url = "https://dl.openwrt.ai/firmware/" ..model.. "/" ..remote_version.. "-openwrt-x86-64-generic-squashfs-combined-efi.img.gz"
    	else
    		download_url = "https://dl.openwrt.ai/firmware/" ..model.. "/" ..remote_version.. "-openwrt-x86-64-generic-squashfs-combined.img.gz"
    		md5 = ""
    	end
    elseif board_name == "x86_generic" then
    	model = "x86_32"
    	check_update()
    	if fs.access("/sys/firmware/efi") then
    		download_url = "https://dl.openwrt.ai/firmware/" ..model.. "/" ..remote_version.. "-openwrt-x86-generic-squashfs-combined-efi.img.gz"
    	else
    		download_url = "https://dl.openwrt.ai/firmware/" ..model.. "/" ..remote_version.. "-openwrt-x86-generic-squashfs-combined.img.gz"
    		md5 = ""
    	end
    elseif board_name:match("phicomm,k3$") or board_name:match("rt%-ac88u$") then
		check_update()
		download_url = "https://dl.openwrt.ai/firmware/" ..model.. "/" ..remote_version.. "-openwrt-" ..target.. "-" ..board_name.. "-squashfs.trx"
    elseif target:match("sunxi") then
		check_update()
		download_url = "https://dl.openwrt.ai/firmware/" ..model.. "/" ..remote_version.. "-openwrt-" ..target.. "-" ..board_name.. "-squashfs-sdcard.img.gz"    
    elseif arch:match("aarch64_generic") or board_name:match("rpi%-") then
		check_update()
		download_url = "https://dl.openwrt.ai/firmware/" ..model.. "/" ..remote_version.. "-openwrt-" ..target.. "-" ..board_name.. "-squashfs-sysupgrade.img.gz"
    else
		check_update()
		download_url = "https://dl.openwrt.ai/firmware/" ..model.. "/" ..remote_version.. "-openwrt-" ..target.. "-" ..board_name.. "-squashfs-sysupgrade.bin"
    end
	

    if needs_update and not download_url then
        return {
            code = 1,
            now_version = get_system_version(),
            version = remote_version,
            error = i18n.translate(
                "New version found, but failed to get new version download url.")
        }
    end

    return {
        code = 0,
        update = needs_update,
        notice = notice,
        now_version = get_system_version(),
        version = remote_version,
        md5 = md5,
        logs = updatelogs,
        url = download_url
    }
end

function to_download(url,md5)
    if not url or url == "" then
        return {code = 1, error = i18n.translate("Download url is required.")}
    end

    sys.call("/bin/rm -f /tmp/firmware_download.*")

    local tmp_file = util.trim(util.exec("mktemp -u -t firmware_download.XXXXXX"))

    local result = api.exec(api.wget, {api._unpack(api.wget_args), "-O", tmp_file, url}, nil, api.command_timeout) == 0

    if not result then
        api.exec("/bin/rm", {"-f", tmp_file})
        return {
            code = 1,
            error = i18n.translatef("File download failed or timed out: %s", url)
        }
    end

	local md5local = sys.exec("echo -n $(md5sum " .. tmp_file .. " | awk '{print $1}')")

	if md5 ~= "" and md5local ~= md5 then
		api.exec("/bin/rm", {"-f", tmp_file})
		return {
            code = 1,
            error = i18n.translatef("Md5 check failed: %s", url)
        }
	end

    return {code = 0, file = tmp_file}
end

function to_flash(file,retain)
    if not file or file == "" or not fs.access(file) then
        return {code = 1, error = i18n.translate("Firmware file is required.")}
    end
    sys.call("/sbin/sysupgrade " ..retain.. " " ..file.. "")

    return {code = 0}
end
