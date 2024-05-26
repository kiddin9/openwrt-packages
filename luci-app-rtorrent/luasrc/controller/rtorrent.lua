-- Copyright 2014-2018 Sandor Balazsi <sandor.balazsi@gmail.com>
-- Licensed to the public under the GNU General Public License.

local nixio = require "nixio"
local dm = require "luci.model.cbi.rtorrent.download"

module("luci.controller.rtorrent", package.seeall)

function index()
	entry({"admin", "rtorrent"},  firstchild(), translate("Torrent"), 45).dependent = false
	entry({"admin", "rtorrent", "main"}, form("rtorrent/main"), translate("Torrent List"), 10).leaf = true
	entry({"admin", "rtorrent", "add"}, form("rtorrent/add", {autoapply=true}), translate("Add Torrent"), 20)
	entry({"admin", "rtorrent", "rss"}, arcombine(cbi("rtorrent/rss"), cbi("rtorrent/rss-rule")), translate("RSS Downloader"), 30).leaf = true
	entry({"admin", "rtorrent", "admin"}, form("rtorrent/admin/rtorrent"), translate("Torrent Settings"), 40)

	entry({"admin", "rtorrent", "info"}, form("rtorrent/torrent/info"), nil).leaf = true
	entry({"admin", "rtorrent", "files"}, form("rtorrent/torrent/files"), nil).leaf = true
	entry({"admin", "rtorrent", "trackers"}, form("rtorrent/torrent/trackers"), nil).leaf = true
	entry({"admin", "rtorrent", "peers"}, form("rtorrent/torrent/peers"), nil).leaf = true

	entry({"admin", "rtorrent", "download"}, call("download"), nil).leaf = true
	entry({"admin", "rtorrent", "downloadall"}, call("downloadall"), nil).leaf = true

	entry({"admin", "rtorrent", "admin", "rtorrent"}, form("rtorrent/admin/rtorrent"), nil).leaf = true
	entry({"admin", "rtorrent", "admin", "rss"}, cbi("rtorrent/admin/rss"), nil).leaf = true
end

function download()
	dm.download_file(nixio.bin.b64decode(luci.dispatcher.context.requestpath[4]))
end

function downloadall()
	dm.download_all(nixio.bin.b64decode(luci.dispatcher.context.requestpath[4]))
end

