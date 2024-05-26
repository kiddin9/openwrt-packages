# OpenWrt netifd scripts to configure connection Fibocom L860-GL
Intel XMM 7360/7650 LTE-A Pro modem

# How-to configure cellular connection
The config stored in /etc/config/network. Example configuration:
```
config interface 'wwan'
	option device '/dev/ttyACM0' # Device serial port
	option proto 'xmm'
	option pdp 'ip' # Connect method IPV4/6 version
	option apn 'internet' # APN Cellular
	option delay '10' # Delay interface to connect
	optiom auth 'auto' # Auth type (auto, pap or chap)
	option username 'username' # username 
	option password 'password' # password
```

# How-to configure interface via LuCi
build and install package luci-proto-xmm

