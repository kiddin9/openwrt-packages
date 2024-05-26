
# luci-app-nginx-manager（Nginx管理器）

更方便的管理openwrt的nginx

### 注意事项
1. 替代默认的uhttpd做为路由后台的web服务器
2. 插件依赖+luci-nginx +luci-ssl-nginx +luci-ssl-openssl，并且会开启路由后台的https功能
3. 插件会替代默认的uhttpd，但并不会删除uhttpd，如果你需要删除uhttpd，需在编译前在根目录执行以下操作：

```bash
sed -i 's/+uhttpd +uhttpd-mod-ubus //g' feeds/luci/collections/luci/Makefile
```

### 效果展示
![nginx-manager][1]

  [1]: https://raw.githubusercontent.com/sundaqiang/openwrt-packages/master/img/nginx-manager.png