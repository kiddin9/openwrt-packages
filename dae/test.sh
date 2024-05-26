#!/bin/sh

case "$1" in
	"dae")
		dae --version | grep "$PKG_VERSION"
		;;
esac
