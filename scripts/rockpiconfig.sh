#!/bin/bash

while getopts ":v:" opt; do
  case $opt in
    v)
      VERSION=$OPTARG
      ;;
  esac
done

PATCH=$(cat /patch)

# This script will be run in chroot under qemu.

echo "Creating Fstab File"

touch /etc/fstab
echo "proc            /proc           proc    defaults        0       0
/dev/mmcblk2p1  /boot           vfat    defaults,utf8,user,rw,umask=111,dmask=000        0       1
tmpfs   /var/log                tmpfs   size=20M,nodev,uid=1000,mode=0777,gid=4, 0 0
tmpfs   /var/spool/cups         tmpfs   defaults,noatime,mode=0755 0 0
tmpfs   /var/spool/cups/tmp     tmpfs   defaults,noatime,mode=0755 0 0
tmpfs   /tmp                    tmpfs   defaults,noatime,mode=0755 0 0
tmpfs   /dev/shm                tmpfs   defaults,nosuid,noexec,nodev        0 0
" > /etc/fstab

echo "Adding PI Modules"
echo "
i2c-dev
" >> /etc/modules

echo "Alsa Raspberry PI Card Ordering"
echo "
options snd-usb-audio nrpacks=1
# USB DACs will have device number 5 in whole Volumio device range
options snd-usb-audio index=5
options snd_bcm2835 index=0" >> /etc/modprobe.d/alsa-base.conf

echo "Installing specific binaries"
apt-get update
apt-get -y install binutils i2c-tools smbclient samba gpiod
# Commenting raspi-config, not sure it is really needed
#apt-get -y install libnewt0.52 whiptail triggerhappy lua5.1 locales

mkdir /lib/modules

echo "Removing unneeded binaries"
apt-get -y remove binutils

echo "adding gpio & spi group and permissions"
groupadd -f --system gpio
groupadd -f --system spi

echo "adding volumio to gpio group and al"
usermod -a -G gpio,i2c,spi,input volumio

echo "Installing raspberrypi-sys-mods System customizations"
unlink /etc/systemd/system/multi-user.target.wants/sshswitch.service
rm /lib/systemd/system/sshswitch.service

echo "Installing winbind here, since it freezes networking"
apt-get install -y winbind libnss-winbind

echo "Cleaning APT Cache and remove policy file"
rm -f /var/lib/apt/lists/*archive*
apt-get clean
rm /usr/sbin/policy-rc.d

#First Boot operations
echo "Signalling the init script to re-size the volumio data partition"
touch /boot/resize-volumio-datapart

cd /
tar -zxvf boot.tar.gz
dpkg -i --force-all /libnpupnp1_4.2.1-2~ppaPPAVERS~SERIES1_arm64.deb
dpkg -i --force-all /libupnpp6_0.21.0-3~ppaPPAVERS~SERIES1_arm64.deb
dpkg -i --force-all /upmpdcli_1.5.16-1~ppaPPAVERS~SERIES1_arm64.deb
dpkg -i --force-all /upmpdcli-spotify_1.5.16-1~ppaPPAVERS~SERIES1_all.deb
dpkg -i --force-all /upmpdcli-qobuz_1.5.16-1~ppaPPAVERS~SERIES1_all.deb
dpkg -i --force-all /sc2mpd_1.1.11-1~ppaPPAVERS~SERIES1_arm64.deb
rm -vf /libnpupnp1_4.2.1-2~ppaPPAVERS~SERIES1_arm64.deb
rm -vf /libupnpp6_0.21.0-3~ppaPPAVERS~SERIES1_arm64.deb
rm -vf /upmpdcli_1.5.16-1~ppaPPAVERS~SERIES1_arm64.deb
rm -vf /upmpdcli-spotify_1.5.16-1~ppaPPAVERS~SERIES1_all.deb
rm -vf /upmpdcli-qobuz_1.5.16-1~ppaPPAVERS~SERIES1_all.deb
rm -vf /sc2mpd_1.1.11-1~ppaPPAVERS~SERIES1_arm64.deb
dpkg -i --force-all /linux-image-current-rockchip64_21.11.0-trunk_arm64.deb
mv /boot/vmlinuz-5.10.87-rockchip64 /boot/Image

sync
