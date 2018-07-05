#!/bin/sh
##
#Volumio system Configuration Script
##
BUILD="arm"
ARCH="armhf"

echo 'Copying Custom Volumio System Files'
#Apt conf file
echo 'Copying ARM related configuration files'
cp volumio/etc/apt/sources.list.$BUILD build/$BUILD/root/etc/apt/sources.list
echo 'Setting time for ARM devices with fakehwclock to build time'
date -u '+%Y-%m-%d %H:%M:%S' > build/$BUILD/root/etc/fake-hwclock.data

#Edimax Power Saving Fix + Alsa modprobe
cp -r volumio/etc/modprobe.d build/$BUILD/root/etc/
#Hosts file
cp -p volumio/etc/hosts build/$BUILD/root/etc/hosts
#Dhcp conf file
cp volumio/etc/dhcp/dhclient.conf build/$BUILD/root/etc/dhcp/dhclient.conf
cp volumio/etc/dhcp/dhcpd.conf build/$BUILD/root/etc/dhcp/dhcpd.conf
#Samba conf file
cp volumio/etc/samba/smb.conf build/$BUILD/root/etc/samba/smb.conf
#Udev confs file (NET)
cp -r volumio/etc/udev build/$BUILD/root/etc/
#Udisks-glue for USB
cp -r volumio/etc/udisks-glue.conf build/$BUILD/root/etc/udisks-glue.conf
#Polkit for USB mounts
cp -r volumio/etc/polkit-1/localauthority/50-local.d/50-mount-as-pi.pkla build/$BUILD/root/etc/polkit-1/localauthority/50-local.d/50-mount-as-pi.pkla
#Inittab file
cp volumio/etc/inittab build/$BUILD/root/etc/inittab
#MOTD
cp volumio/etc/motd build/$BUILD/root/etc/motd
#SSH
cp volumio/etc/ssh/sshd_config build/$BUILD/root/etc/ssh/sshd_config
#Mpd
cp volumio/etc/mpd.conf build/$BUILD/root/etc/mpd.conf
chmod 777 build/$BUILD/root/etc/mpd.conf
#Log via JournalD in RAM
cp volumio/etc/systemd/journald.conf build/$BUILD/root/etc/systemd/journald.conf
#Volumio SystemD Services
cp -r volumio/lib build/$BUILD/root/
# Netplug
# removed , we are using ifplugd
#cp -rp volumio/etc/netplug build/$BUILD/root/etc/
#chmod +x build/$BUILD/root/etc/netplug/netplug
# Network
cp -r volumio/etc/network/* build/$BUILD/root/etc/network
# Wpa Supplicant
echo " " > build/$BUILD/root/etc/wpa_supplicant/wpa_supplicant.conf
chmod 777 build/$BUILD/root/etc/wpa_supplicant/wpa_supplicant.conf
#Shairport
cp volumio/etc/shairport-sync.conf build/$BUILD/root/etc/shairport-sync.conf
chmod 777 build/$BUILD/root/etc/shairport-sync.conf
#nsswitch
cp volumio/etc/nsswitch.conf build/$BUILD/root/etc/nsswitch.conf
#firststart
cp volumio/bin/firststart.sh build/$BUILD/root/bin/firststart.sh
#hotspot
cp volumio/bin/hotspot.sh build/$BUILD/root/bin/hotspot.sh
#dynswap
cp volumio/bin/dynswap.sh build/$BUILD/root/bin/dynswap.sh
#Wireless
cp volumio/bin/wireless.js build/$BUILD/root/volumio/app/plugins/system_controller/network/wireless.js
#dhcpcd
cp -rp volumio/etc/dhcpcd.conf build/$BUILD/root/etc/
#wifi pre script
cp volumio/bin/wifistart.sh build/$BUILD/root/bin/wifistart.sh
chmod a+x build/$BUILD/root/bin/wifistart.sh
#udev script
cp volumio/bin/rename_netiface0.sh build/$BUILD/root/bin/rename_netiface0.sh
chmod a+x build/$BUILD/root/bin/rename_netiface0.sh
#Plymouth & upmpdcli files
cp -rp volumio/usr/*  build/$BUILD/root/usr/
#SSH
cp volumio/bin/volumiossh.sh build/$BUILD/root/bin/volumiossh.sh
chmod a+x build/$BUILD/root/bin/volumiossh.sh
#CPU TWEAK
cp volumio/bin/volumio_cpu_tweak build/$BUILD/root/bin/volumio_cpu_tweak
chmod a+x build/$BUILD/root/bin/volumio_cpu_tweak
#LAN HOTPLUG
cp volumio/etc/default/ifplugd build/$BUILD/root/etc/default/ifplugd

echo 'Done Copying Custom Volumio System Files'