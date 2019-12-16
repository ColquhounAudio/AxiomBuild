#!/bin/sh

# NOTE: this script must only use really basic shell features as it must be able to run on limited
# busybox installs (synology, etc)

if [ x"$1" = "x--update" ]; then

    doerror() {
        echo ERROR: $1
        exit 1
    }

    PKG="$2"
    ROOTDIR="$3"

    echo Install package is at: $PKG
    echo Installing to: $ROOTDIR

    echo Removing any old update...
    rm -rf "$ROOTDIR/.update"*

    echo Untarring new install to "$ROOTDIR/.update.tmp"
    mkdir "$ROOTDIR/.update.tmp" || doerror "failed to mkdir $ROOTDIR/.update.tmp"
    tar xf "$PKG" -C "$ROOTDIR/.update.tmp" || doerror "failed to tar xf $PKG -C $ROOTDIR/.update.tmp"

    mv "$ROOTDIR/.update.tmp" "$ROOTDIR/.update" || doerror "failed to mv $ROOTDIR/.update.tmp to $ROOTDIR/.update"

    echo Cleaning up...
    rm -rf "$PKG"

    echo Installation was a success!

    exit 0

else
    clean_up() {
        kill $PID
        exit 0
    }
    trap clean_up EXIT

    ROOTDIR="`dirname \"$0\"`"
    ROOTDIR="`( cd \"$ROOTDIR\" && pwd )`"

    "$ROOTDIR/Bridge/RoonBridge" "$@" &
    PID=$!
    wait $PID
    R=$?
    if [ $R -eq 122 ]; then
        exec $0 "$@"
    fi
    exit $R
fi
