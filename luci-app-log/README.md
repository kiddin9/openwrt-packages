# luci-app-log-viewer
Advanced syslog and kernel log (tail, search, etc) for LuCI (OpenWrt webUI).

OpenWrt >= 19.07.

Supported LuCI themes: luci-theme-bootstrap, luci-theme-material, luci-theme-openwrt-2020.

## Installation notes

**OpenWrt >= 21.02:**

    wget --no-check-certificate -O /tmp/luci-app-log-viewer_1.1-5_all.ipk https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-app-log-viewer_1.1-5_all.ipk
    opkg install /tmp/luci-app-log-viewer_1.1-5_all.ipk
    rm /tmp/luci-app-log-viewer_1.1-5_all.ipk
    service rpcd restart

i18n-ru:

    wget --no-check-certificate -O /tmp/luci-i18n-log-viewer-ru_1.1-5_all.ipk https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-i18n-log-viewer-ru_1.1-5_all.ipk
    opkg install /tmp/luci-i18n-log-viewer-ru_1.1-5_all.ipk
    rm /tmp/luci-i18n-log-viewer-ru_1.1-5_all.ipk

**OpenWrt 19.07:**

    wget --no-check-certificate -O /tmp/luci-app-log_0.4-6_all.ipk https://github.com/gSpotx2f/packages-openwrt/raw/master/19.07/luci-app-log_0.4-6_all.ipk
    opkg install /tmp/luci-app-log_0.4-6_all.ipk
    rm /tmp/luci-app-log_0.4-6_all.ipk
    service rpcd restart

i18n-ru:

    wget --no-check-certificate -O /tmp/luci-i18n-log-ru_0.4-6_all.ipk https://github.com/gSpotx2f/packages-openwrt/raw/master/19.07/luci-i18n-log-ru_0.4-6_all.ipk
    opkg install /tmp/luci-i18n-log-ru_0.4-6_all.ipk
    rm /tmp/luci-i18n-log-ru_0.4-6_all.ipk

## Screenshots:

Kernel log:

![](https://github.com/gSpotx2f/luci-app-log/blob/master/screenshots/01.jpg)

System log (logd):

![](https://github.com/gSpotx2f/luci-app-log/blob/master/screenshots/02.jpg)

Filter settings:

![](https://github.com/gSpotx2f/luci-app-log/blob/master/screenshots/03.jpg)

System log (syslog-ng):

![](https://github.com/gSpotx2f/luci-app-log/blob/master/screenshots/04.jpg)

## Mod lines (OpenWrt >= 21.02):

    wget --no-check-certificate -O /www/luci-static/resources/view/log-viewer/log-widget.js https://github.com/gSpotx2f/luci-app-log/raw/master/dev-mods-examples/mod-lines/htdocs/luci-static/resources/view/log-viewer/log-widget.js

![](https://github.com/gSpotx2f/luci-app-log/blob/master/dev-mods-examples/mod-lines/screenshots/01.jpg)

## Mod textarea (OpenWrt >= 21.02):

    wget --no-check-certificate -O /www/luci-static/resources/view/log-viewer/log-widget.js https://github.com/gSpotx2f/luci-app-log/raw/master/dev-mods-examples/mod-textarea/htdocs/luci-static/resources/view/log-viewer/log-widget.js

![](https://github.com/gSpotx2f/luci-app-log/blob/master/dev-mods-examples/mod-textarea/screenshots/01.jpg)
