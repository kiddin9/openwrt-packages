#!/bin/sh -e

[ -d /etc/chinadns-ng ] || mkdir /etc/chinadns-ng

wget https://raw.githubusercontent.com/pexcn/daily/gh-pages/chnroute/chnroute.txt -O /etc/chinadns-ng/chnroute.tmp
mv -f /etc/chinadns-ng/chnroute.tmp /etc/chinadns-ng/chnroute.txt

wget https://raw.githubusercontent.com/pexcn/daily/gh-pages/chnroute/chnroute6.txt -O /etc/chinadns-ng/chnroute6.tmp
mv -f /etc/chinadns-ng/chnroute6.tmp /etc/chinadns-ng/chnroute6.txt

wget https://raw.githubusercontent.com/pexcn/daily/gh-pages/gfwlist/gfwlist.txt -O /etc/chinadns-ng/gfwlist.tmp
mv -f /etc/chinadns-ng/gfwlist.tmp /etc/chinadns-ng/gfwlist.txt
#sed -n -i '1,100p' /etc/chinadns-ng/gfwlist.txt

wget https://raw.githubusercontent.com/pexcn/daily/gh-pages/chinalist/chinalist.txt -O /etc/chinadns-ng/chinalist.tmp
mv -f /etc/chinadns-ng/chinalist.tmp /etc/chinadns-ng/chinalist.txt
#sed -n -i '1,100p' /etc/chinadns-ng/chinalist.txt

/etc/init.d/chinadns-ng restart
