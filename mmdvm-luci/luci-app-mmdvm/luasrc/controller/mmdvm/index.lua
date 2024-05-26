-- Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
-- This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0

module("luci.controller.mmdvm.index", package.seeall)

function index()
	local root = node()
	if not root.target then
		root.target = alias("mmdvm")
		root.index = true
	end
end

