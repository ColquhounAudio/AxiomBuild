#!/bin/sh


BUILD="arm"
ARCH="armhf"
CONF="multistrap-axiomair-pi3.conf"
if [ -f ./Volumio.sqsh ];
then
	mv ./Volumio.sqsh ./Volumio.sqsh.old
fi
mkdir -p "build/$BUILD/root/etc/apt/apt.conf.d/"
cp -r /etc/apt/trusted.gpg* build/$BUILD/root/etc/apt
echo 'Acquire::http::Proxy "http://192.168.1.9:3142";' > build/$BUILD/root/etc/apt/apt.conf.d/00aptproxy
multistrap -a "$ARCH" -f "$CONF"

cp /usr/bin/qemu-arm-static "build/$BUILD/root/usr/bin/"
rm build/$BUILD/root/etc/apt/apt.conf.d/00aptproxy

