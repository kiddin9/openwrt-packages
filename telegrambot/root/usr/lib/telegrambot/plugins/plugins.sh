#!/bin/sh

IFS=
echo -ne "Aviable commands are:\n"

cd /usr/lib/telegrambot/plugins

for p in $(find . -type f -print -o -name . -o -prune |sed -e 's/.sh//g' -e 's/\.//g'); do
	echo -ne "*$p*\n"
done
