802.11k Neighbor Report distributor daemon
==========================================

Original source: https://github.com/simonyiszk/openwrt-rrm-nr-distributor

## Features

- Multi-network support (different SSID for different networks)
- STA dependent band steering by advertising the other BSSes of the same AP
- Works out of the box after umdns is working
- Not too much but enough logs

## Installation

- Configure all your OpenWRT devices for the same SSID for each layer 2 network
- Install umdns and configure it (Pay attention to config the interface in the config file, setup your firewall, seccomp workaround etc. Finally ubus call umdns browse should show your other devices' dropbear)
- Copy initscript to /etc/init.d/rrm_nr
- Copy bin to /usr/bin/rrm_nr
- Run /etc/init.d/rrm_nr enable and /etc/init.d/rrm_nr start commands
- Check the syslog for the results

## Known issues

- SSIDs with '|' character are not supported at the moment
- With large number of APs (>20) the full umdns update takes a few interations/minutes
