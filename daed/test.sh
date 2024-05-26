#!/bin/sh

case "$1" in
	"daed")
		daed --version | grep "$PKG_VERSION"
		;;
esac
