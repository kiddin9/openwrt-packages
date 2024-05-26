# mrtg-openwrt
Packaging MRTG with OpenWrt SDK

How-to compile:
```
cd feeds/package/net
git clone https://github.com/koshev-msk/mrtg-openwrt.git
cd ../../..
./scripts feeds update -a; ./scripts/feeds install -a
make -j $(($(nproc)+1)) package/feeds/packages/mrtg-openwrt/compile
```
