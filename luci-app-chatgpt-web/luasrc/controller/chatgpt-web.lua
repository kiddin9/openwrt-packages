-- Copyright (C) 2023  sirpdboy  <herboy2008@gmail.com> https://github.com/sirpdboy/chatgpt-web.git
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.chatgpt-web", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/chatgpt-web") then
		return
	end

    local e = entry({"admin",  "services", "chatgpt-web"}, alias("admin", "services", "chatgpt-web", "setting"),_("Chatgpt Web"), 20)
    e.dependent=false
    e.acl_depends = { "luci-app-chatgpt-web" }
	entry({"admin", "services", "chatgpt-web", "setting"}, cbi("chatgpt-web"), _("Base Setting"), 10).leaf=true
        entry({"admin",  "services", "chatgpt-web", "chatgpt-web"}, cbi("chatgpt",{hideapplybtn=true, hidesavebtn=true, hideresetbtn=true}), _("Chatgpt Web"), 30).leaf=true
end

