-- 定义luci.controller.feishuvpn模块
module("luci.controller.feishuvpn", package.seeall)

-- index函数：配置FeiShuVpn的管理界面入口
function index()
  -- 创建admin/services/feishuvpn目录下的入口，重定向到config页面
  -- dependent = true表示该入口依赖于其他服务
  entry({"admin", "services", "feishuvpn"}, alias("admin", "services", "feishuvpn", "config"), _("FeiShuVpn"), 30).dependent = true
  
  -- 创建admin/services/feishuvpn/config页面，用于配置FeiShuVpn
  entry({"admin", "services", "feishuvpn", "config"}, cbi("feishuvpn"))
end