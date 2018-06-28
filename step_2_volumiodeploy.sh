#!/bin/sh
BUILD="arm"
ARCH="armhf"

echo "Build for arm/armv7/armv8 platform, copying qemu"
cp /usr/bin/qemu-arm-static "build/$BUILD/root/usr/bin/"
cp scripts/volumioconfig.sh "build/$BUILD/root"

mount /dev "build/$BUILD/root/dev" -o bind
mount /proc "build/$BUILD/root/proc" -t proc
mount /sys "build/$BUILD/root/sys" -t sysfs

echo 'Cloning Volumio Node Backend'
mkdir "build/$BUILD/root/volumio"

git clone --depth 1 -b AxiomAirV2 --single-branch https://github.com/ColquhounAudio/Volumio2.git build/$BUILD/root/volumio
echo 'Cloning Volumio UI'
git clone --depth 1 -b dist --single-branch https://github.com/ColquhounAudio/Volumio2-UI.git "build/$BUILD/root/volumio/http/www"
echo "Adding os-release infos"
{
	echo "VOLUMIO_FE_VERSION=\"$(git --git-dir "build/$BUILD/root/volumio/http/www/.git" rev-parse HEAD)\""
	echo "VOLUMIO_BE_VERSION=\"$(git --git-dir "build/$BUILD/root/volumio/.git" rev-parse HEAD)\""
	echo "VOLUMIO_ARCH=\"${BUILD}\""
} >> "build/$BUILD/root/etc/os-release"

rm -rf build/$BUILD/root/volumio/http/www/.git

chroot "build/$BUILD/root" /bin/bash -x <<'EOF'
su -
./volumioconfig.sh
EOF

echo "Unmounting Temp devices"
umount -l "build/$BUILD/root/dev"
umount -l "build/$BUILD/root/proc"
umount -l "build/$BUILD/root/sys"

