-- Compiling airos with the wifidog package running at boot

Because airos doesn't have a package manager like opkf and has a (mostly) read-only file system, we need to build the the firmware with wifidog in it to have wifidog running on airos

1- Get the latest wifidog source code tarball from sourceforge (http://sourceforge.net/projects/wifidog/files/) and copy it to the ~/dev/wifidog directory

2- Get the wifidog airos package directory

cd ~/dev/wifidog
wget http://dev.wifidog.org/wiki/doc/install/airos/wifidog_airos.tar.gz
tar xvzf wifidog_airos.tar.gz

If compiling from source, this directory is located in wifidog/contrib/airos

3- Download the airos SDK from http://www.ubnt.com/support/downloads and copy it to the ~/dev/airos directory

4- Untar the SDK and prepare the files

cd ~/dev/airos
tar xvjf SDK.UBNT.v5.2.tar.bz2
cd SDK.UBNT.v5.2

cd openwrt/package
ln -s ~/dev/wifidog/airos/wifidog/ 
cd ../dl
ln -s ~/dev/wifidog/wifidog-20090925.tar.gz

cd ../..
patch -p1 < openwrt/package/wifidog/files.patch

5- Prepare the wifidog.conf file for your network, since airos is readonly, changes to the config files cannot be done in the router

cd ~/dev/airos/SDK.UBNT.v5.2/openwrt
mkdir -p files/usr/etc
cp package/wifidog/files/wifidog.conf files/usr/etc/wifidog.conf

6- Edit the files/usr/etc/wifidog.conf file for your authentication server settings.  Also the GatewayInterface may need to be changed if you are not using a SOHO router configuration (eth0 for SOHO router, ath0 for router)

7- Make the os

make world V=99

8- Your new image should be available in the openwrt/bin directory as XM.v5.2....bin
