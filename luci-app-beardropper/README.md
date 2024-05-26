luci-app-beardropper
===

[Preview][preview]
---
luci-app-beardropper, a log examination script w/ iptables firewall rule generation response.
 
 This is the LuCI app built for the elegant firewall rule generation on-the-fly script [bearDropper][bearDropper], only a few modifications were made to work with Luci.
 

 
Targets/Devices
---
Written in shell scripts, so it shall work all good on all devices.


Config
---
The config file path is: `/etc/config/beardropper`  and this is the uci configuration format.



Compile
---
RECOMMENDED!!!! (推荐使用右边的feeds---->)You can use [natelol feeds][feeds]


OR


0. Go under `openwrt/`

1. Make your own local feeds, say a folder `mkdir yourfeeds`

2. Clone master under feeds to have `git clone https://github.com/natelol/luci-app-beardropper yourefeeds/luci-app-beardropper`

3. Append  `src-link yourfeeds /path/to/openwrt/yourfeeds` in the file `openwrt/feeds.conf(.default)`  

4. Run following scripts under `openwrt`:

```bash
# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a

# M select luci-app-beardropper in LuCI -> 3. Applications also 2. Modules->Translations if you want translations together
make menuconfig
# compile
make package/feeds/luci-app-beardropper/compile V=99
```

Logs
---
`2020-05-21` Added a new tab listing the blocked IPs.


 [preview]: https://github.com/natelol/luci-app-beardropper/tree/master/preview
 [bearDropper]: https://github.com/robzr/bearDropper
 [feeds]: https://github.com/natelol/natelol