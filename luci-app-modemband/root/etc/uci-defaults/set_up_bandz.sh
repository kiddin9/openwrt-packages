#!/bin/sh
# Copyright 2022 Rafał Wabik (IceG) - From eko.one.pl forum
# MIT License

BANDZ=$(modemband.sh getbands)

WORKBANDZ=$(echo $BANDZ | tr " " ,)
if [ $WORKBANDZ != null ]; then
uci set modemband.@modemband[0].set_bands=$WORKBANDZ
uci commit modemband
fi
