#!/bin/sh

# run in router
APPNAME=$1

if [ -z "${APPNAME}" ]; then
  APPNAME=plex
fi

mkdir -p /usr/lib/lua/luci/view/${APPNAME}
cp ./luasrc/controller/${APPNAME}.lua /usr/lib/lua/luci/controller/
cp ./luasrc/view/${APPNAME}/* /usr/lib/lua/luci/view/${APPNAME}/
cp -rf ./luasrc/model/* /usr/lib/lua/luci/model/
cp -rf ./root/* /
rm -rf /tmp/luci-*

