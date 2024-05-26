-- Copyright 2014-2018 Sandor Balazsi <sandor.balazsi@gmail.com>
-- Licensed to the public under the GNU General Public License.

local rtorrent = require "rtorrent"
local common = require "luci.model.cbi.rtorrent.common"

local config = rtorrent.batchcall({
	"throttle.global_up.max_rate", "throttle.global_down.max_rate",
	"throttle.max_downloads.global", "throttle.max_uploads.global",
	"throttle.max_uploads",
	"throttle.min_peers.normal", "throttle.max_peers.normal",
	"throttle.min_peers.seed", "throttle.max_peers.seed"
})

local function set_config(key, value)
	if tonumber(value) ~= config[key] then
		rtorrent.call(key .. ".set", "", value)
		luci.http.redirect(luci.dispatcher.build_url("admin/rtorrent/admin/rtorrent"))
	end
end

f = SimpleForm("rtorrent", translate("Admin - rTorrent"))

speed = f:section(SimpleSection)
speed.title = translate("Bandwidth limits")
speed.render = function(self, ...)
	luci.template.render("rtorrent/tabmenu", { self = {
		pages = common.get_admin_pages(),
		page = "rTorrent"
	}})
	SimpleSection.render(self, ...)
end

upload_rate = speed:option(Value, "upload_rate", translate("Upload limit (KiB/sec)"),
	translate("Global upload rate (0: unlimited)"))
upload_rate.rmempty = false
upload_rate.default = config["throttle.global_up.max_rate"] / 1024
upload_rate.datatype = "uinteger"
function upload_rate.write(self, section, value)
	set_config("throttle.global_up.max_rate", value .. "k")
end

download_rate = speed:option(Value, "download_rate", translate("Download limit (KiB/sec)"),
	translate("Global downlaod rate (0: unlimited)"))
download_rate.rmempty = false
download_rate.default = config["throttle.global_down.max_rate"] / 1024
download_rate.datatype = "uinteger"
function download_rate.write(self, section, value)
	set_config("throttle.global_down.max_rate", value .. "k")
end


global_limits = f:section(SimpleSection)
global_limits.title = translate("Global limits")

max_downloads_global = global_limits:option(Value, "max_downloads_global", translate("Download slots"),
	translate("Maximum number of simultaneous downloads"))
max_downloads_global.rmempty = false
max_downloads_global.default = config["throttle.max_downloads.global"]
max_downloads_global.datatype = "uinteger"
function max_downloads_global.write(self, section, value)
	set_config("throttle.max_downloads.global", value)
end

max_uploads_global = global_limits:option(Value, "max_uploads_global", translate("Upload slots"),
	translate("Maximum number of simultaneous uploads"))
max_uploads_global.rmempty = false
max_uploads_global.default = config["throttle.max_uploads.global"]
max_uploads_global.datatype = "uinteger"
function max_uploads_global.write(self, section, value)
	set_config("throttle.max_uploads.global", value)
end


torrent_limits = f:section(SimpleSection)
torrent_limits.title = translate("Torrent limits")

max_uploads = torrent_limits:option(Value, "max_uploads", translate("Maximum uploads"),
	translate("Maximum number of simultanious uploads per torrent"))
max_uploads.rmempty = false
max_uploads.default = config["throttle.max_uploads"]
max_uploads.datatype = "uinteger"
function max_uploads.write(self, section, value)
	set_config("throttle.max_uploads", value)
end

min_peers = torrent_limits:option(Value, "min_peers", translate("Minimum peers"),
	translate("Minimum number of peers to connect to per torrent"))
min_peers.rmempty = false
min_peers.default = config["throttle.min_peers.normal"]
min_peers.datatype = "uinteger"
function min_peers.write(self, section, value)
	set_config("throttle.min_peers.normal", value)
end

max_peers = torrent_limits:option(Value, "max_peers", translate("Maximum peers"),
	translate("Maximum number of peers to connect to per torrent"))
max_peers.rmempty = false
max_peers.default = config["throttle.max_peers.normal"]
max_peers.datatype = "uinteger"
function max_peers.write(self, section, value)
	set_config("throttle.max_peers.normal", value)
end

min_peers_seed = torrent_limits:option(Value, "min_peers_seed", translate("Minimum seeds"),
	translate("Minimum number of seeds for completed torrents (-1 = same as peers)"))
min_peers_seed.rmempty = false
min_peers_seed.default = config["throttle.min_peers.seed"]
min_peers_seed.datatype = "integer"
function min_peers_seed.write(self, section, value)
	set_config("throttle.min_peers.seed", value)
end

max_peers_seed = torrent_limits:option(Value, "max_peers_seed", translate("Maximum seeds"),
	translate("Maximum number of seeds for completed torrents (-1 = same as peers)"))
max_peers_seed.rmempty = false
max_peers_seed.default = config["throttle.max_peers.seed"]
max_peers_seed.datatype = "integer"
function max_peers_seed.write(self, section, value)
	set_config("throttle.max_peers.seed", value)
end

-- dir = f:field(DummyValue, "dummy", luci.dispatcher.context.authuser)

return f

