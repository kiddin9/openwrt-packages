#!/bin/bash
# dependent: curl tar 
#
# LuCI Tiny File Manager
# Author: muink
# Github: https://github.com/muink/luci-app-tinyfilemanager
#

# PKGInfo
REPOURL='https://github.com/prasathmani/tinyfilemanager'
PKGNAME='tinyfilemanager'
VERSION='2.5.3'
#
PKG_DIR=$PKGNAME-$VERSION
REF_DIR="assets"
#
INDEXPHP="tinyfilemanager.php"
#CFGSAMPl="config-sample.php"
LANGFILE="translation.json"


PROJDIR="$(cd "$(dirname "$0")"; pwd)" # <--
WORKDIR="$PROJDIR/htdocs/$PKGNAME" # <--
mkdir -p "$WORKDIR" 2>/dev/null
cd $WORKDIR



# Clear Old version
rm -rf *

# Download Repository
grep -qE "^(master|main)$" <<< "$VERSION" && refs=heads || refs=tags
curl -L https://codeload.github.com/prasathmani/tinyfilemanager/tar.gz/refs/$refs/$VERSION | tar -xvz -C "$WORKDIR"

# Version Check
if   [ -z "$(sed -En "/^\\\$external = array\(/,/^\);/p" "$PKG_DIR/$INDEXPHP")" ]; then
    online=y ver_cc=old # <= 2.5.3
elif [ -n "$(sed -En "/^\\\$external = array\(/,/^\);/{s,^(.+=\")(http(s)?://.+/)([^/]+\.(css|js))(\".+),\4,p}" "$PKG_DIR/$INDEXPHP")" ]; then
    online=y ver_cc=master
else
    online=n ver_cc=offline
fi
[ "$online" = "y" ] && {

# Preprocessing
sed -Ei "/<link rel=\"(preconnect|dns-prefetch)\"/d" "$PKG_DIR/$INDEXPHP"
[ "$ver_cc" = "old" ] && {
    FM_HIGHLIGHTJS_STYLE=$(sed -En "s|^\\\$highlightjs_style = *'([^']*)';|\1|p" "$PKG_DIR/$INDEXPHP")
    sed -i "s|<?php echo FM_HIGHLIGHTJS_STYLE ?>|\$FM_HIGHLIGHTJS_STYLE|g" "$PKG_DIR/$INDEXPHP"
}
[ "$ver_cc" = "master" ] && {
    __highlightjs_style=$(sed -En "s|^\\\$highlightjs_style = *'([^']*)';|\1|p" "$PKG_DIR/$INDEXPHP")
    sed -i "s|' . \$highlightjs_style . '|\$__highlightjs_style|" "$PKG_DIR/$INDEXPHP"
}

# Download CDN Used
mkdir -p "$REF_DIR" 2>/dev/null
[ "$ver_cc" = "old" ] && refurl=($(sed -En "s,^.+=\"(https?://.+\.(css|js))\".+,\1,p" "$PKG_DIR/$INDEXPHP" | sort -u ))
[ "$ver_cc" = "master" ] && refurl=($(sed -En "/^\\\$external /,/^\);/{s,^.+=\"(http(s)?://.+\.(css|js))\".+,\1, p}" "$PKG_DIR/$INDEXPHP" | sort -u ))
ref=
url=
out=
type=

# \.(css|js) main ref
for _i in $(seq 0 1 $[ ${#refurl[@]} -1 ]); do
    eval "url=${refurl[$_i]}"
    out=${url##*/}
    type=${url##*.}

    curl -Lo $out $url
    mkdir -p "$REF_DIR/$type" 2>/dev/null
    mv --backup $out "$REF_DIR/$type/"
done

ref=$(for _p in $(find * -type f ! -path "$PKG_DIR/*"); do \
        sed -E "s/(,|;)/\1\n/g" $_p | grep -E "\burl\([^\)]+\)" | grep -Ev "\burl\(\"data:image" >/dev/null; \
        [ "$?" == "0" ] && echo $_p; \
    done)

# ref of main ref
for _i in $ref; do
    suburl=($(sed -E "s/(,|;)/\1\n/g" $_i | grep -E "\burl\([^\)]+\)" | grep -Ev "\burl\(\"data:image" | sed -En "s|^[^']+'([^']+)'.+|\1| p"))
    hosturl=$(for _ in "${refurl[@]}"; do grep "${_i##*/}" <<< "$_"; done)

    for _j in $(seq 0 1 $[ ${#suburl[@]} -1 ]); do
        url="${suburl[$_j]}"
        out=${url%%\?*}
        type=${hosturl##*.}

        mkdir -p "$REF_DIR/$type/${out%/*}" 2>/dev/null
        curl -Lo ${out##*/} "${hosturl%/*}/$url"
        mv -f ${out##*/} "$REF_DIR/$type/$out"
    done
done

# Post-processing
[ "$ver_cc" = "old" ] && sed -i "s|\$FM_HIGHLIGHTJS_STYLE|<?php echo FM_HIGHLIGHTJS_STYLE ?>|g" "$PKG_DIR/$INDEXPHP"
[ "$ver_cc" = "master" ] && sed -i "s|\$__highlightjs_style|' . \$highlightjs_style . '|" "$PKG_DIR/$INDEXPHP"

# Hotfix

# Migrating to Local Reference
sed -Ei "s,^(.+=\")https?://.+/([^/]+\.(css|js))(\".+),\1$REF_DIR/\3/\2\4," "$PKG_DIR/$INDEXPHP"

}

# FixED
[ "$ver_cc" = "master" ] || sed -Ei "/^if \(\\\$use_auth\) \{/,/^}/{/\/\/ Logging In/,/\/\/ Form/{s|(fm_redirect\().+|\1FM_SELF_URL);|g}}" "$PKG_DIR/$INDEXPHP"

# Clean up and Done
[ -d "$PKG_DIR/$REF_DIR" ] && cp -rf "$PKG_DIR/$REF_DIR" .
mv -f "$PKG_DIR/$INDEXPHP" ./index.php
#mv -f "$PKG_DIR/$CFGSAMPl" .
mv -f "$PKG_DIR/$LANGFILE" .
rm -rf "$PKG_DIR"

# Package
sed -Ei "/^VERSION=/{s|(VERSION:=)[^\}]*|\1$VERSION|}" "$PROJDIR/root/usr/libexec/tinyfilemanager-update"
sed -Ei "s|(VERSION=).*|\1'$VERSION'|" "$PROJDIR/root/etc/init.d/tinyfilemanager"
sed -Ei "s|(pkgversion =).*|\1 '$VERSION';|" "$PROJDIR/htdocs/luci-static/resources/view/tinyfilemanager/config.js"
sed -Ei "s|(PKG_VERSION:=)[^-]+|\1$VERSION|" "$PROJDIR/Makefile"
tar -czvf index.tgz * --owner=0 --group=0 --no-same-owner --no-same-permissions --remove-files
