
# luci-app-supervisord（进程管理器）

一款面向Luci的简单的任务管理器，基于 [supervisord](https://github.com/ochinchina/supervisord)

### 特性
- 这是一款进程管理软件，类似于pm2
- 需求主要是部分插件是调用项目的成品，设置项少的其实自己下载更新也蛮不错
- nodejs和python的程序也可以在这里运行，前提是你固件已经有编译好nodejs和python
- 插件没附带二进制文件，第一次使用需要直接点按钮更新。如果更新失败，自行去项目下载二进制文件。
- 配置文件说明:

```ini
;需要备份文件的完整路径，多个文件以||分割，必须
;backupfile=/usr/bin/xxxxx||/etc/yyyyy
backupfile=

;获取版本号命令，必须
;getversions=xxxxx version
getversions=
```
### 效果展示
![supervisord-1][1]
![supervisord-2][2]

  [1]: https://raw.githubusercontent.com/sundaqiang/openwrt-packages/master/img/supervisord-1.png
  [2]: https://raw.githubusercontent.com/sundaqiang/openwrt-packages/master/img/supervisord-2.png