#!/bin/sh


BUILD="arm"
ARCH="armhf"
CONF="multistrap-axiomair-pi3.conf"
mkdir -p "build/$BUILD"
mkdir -p "build/$BUILD/root"
multistrap -a "$ARCH" -f "$CONF"

cp /usr/bin/qemu-arm-static "build/$BUILD/root/usr/bin/"

