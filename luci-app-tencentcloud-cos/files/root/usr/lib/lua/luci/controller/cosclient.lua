module("luci.controller.cosclient", package.seeall)

function index()
	    entry({"admin", "tencentcloud"}, firstchild(), "腾讯云设置", 30).dependent=false                                                
        entry({"admin", "tencentcloud", "cosclient"}, cbi("cosclient"), _("对象存储（COS）"), 1)
        end