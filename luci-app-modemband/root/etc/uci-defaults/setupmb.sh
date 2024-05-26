#!/bin/sh
# Copyright 2020-2023 Rafał Wabik (IceG) - From eko.one.pl forum
# MIT License

chmod +x /usr/bin/modemband.sh 2>&1 &
chmod +x /usr/bin/loaded.sh 2>&1 &
rm -rf /tmp/luci-indexcache 2>&1 &
rm -rf /tmp/luci-modulecache/ 2>&1 &
exit 0
