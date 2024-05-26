#!/bin/sh
# Run this to generate all the initial makefiles, etc.
#
# $Id$

if [ -r Makefile ]
then
	echo "Doing distclean"
	make distclean
fi

if [ "X$1" != "X" ]
then
	BUILDROOT=`echo "$1" | sed 's/^[^=]*[=]//'`

	OLDCC=${CC}
	OLDRANLIB=${RANLIB}
	OLDAR=${AR}

	CC=${BUILDROOT}/build_mipsel/staging_dir/bin/mipsel-linux-uclibc-gcc
	RANLIB=${BUILDROOT}/build_mipsel/staging_dir/bin/mipsel-linux-uclibc-ranlib
	AR=${BUILDROOT}/build_mipsel/staging_dir/bin/mipsel-linux-uclibc-ar

	POSTCONF=--host=mipsel

	export CC
	export RANLIB
	export AR
else
	OLDCC=${CC}
	OLDRANLIB=${RANLIB}
	OLDAR=${AR}
	POSTCONF=
fi

echo "Running mkdir -p config"
mkdir -p config

if [ "X"`uname` = "XDarwin" ]
then
	echo "Running glibtoolize --force"
	glibtoolize --force
else
	echo "Running libtoolize --force"
	libtoolize --force
fi

echo "Running aclocal"
aclocal
echo "Running autoheader"
autoheader
echo "Running automake -a"
automake -a
echo "Running autoconf"
autoconf
echo "Running ./configure ${POSTCONF} --enable-maintainer-mode  $conf_flags $@"
./configure ${POSTCONF} --enable-maintainer-mode $conf_flags "$@"

CC=${OLDCC}
RANLIB=${OLDRANLIB}
AR=${OLDAR}

export CC
export RANLIB
export AR
