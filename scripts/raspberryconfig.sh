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
/dev/mmcblk1p1  /boot           vfat    defaults,utf8,user,rw,umask=111,dmask=000        0       1
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

echo "Adding Raspberrypi.org Repo"
echo "deb http://archive.raspberrypi.org/debian/ buster main ui
deb-src http://archive.raspberrypi.org/debian/ buster main ui
" >> /etc/apt/sources.list.d/raspi.list
echo "deb http://deb.debian.org/debian buster-backports main non-free
" >> /etc/apt/sources.list.d/backports.list


echo "Adding Raspberrypi.org Repo Key"
wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | sudo apt-key add -

echo "Installing R-pi specific binaries"
apt-get update
apt-get -y install binutils i2c-tools smbclient samba libraspberrypi-bin gpiod
# Commenting raspi-config, not sure it is really needed
#apt-get -y install libnewt0.52 whiptail triggerhappy lua5.1 locales

echo "Installing Kernel from Rpi-Update"
# sudo curl -L --output /usr/bin/rpi-update https://raw.githubusercontent.com/ColquhounAudio/rpi-update/master/rpi-update && sudo chmod +x /usr/bin/rpi-update
#sudo curl -L --output /usr/bin/rpi-update https://raw.githubusercontent.com/raspberrypi/rpi-update/master/rpi-update && sudo chmod +x /usr/bin/rpi-update

touch /boot/start.elf
mkdir /lib/modules


KERNEL_VERSION="5.10.63"

case $KERNEL_VERSION in
    "4.14.61")
      KERNEL_REV="1133"
      KERNEL_COMMIT="e16b6270dfa675f2a99545e611d2e834dbc2a064"
      FIRMWARE_COMMIT=$KERNEL_COMMIT
      ;;
    "5.10.63")
      KERNEL_REV="1450"
      KERNEL_COMMIT="64132d67d3e083076661628203a02d27bf13203c"
      FIRMWARE_COMMIT=$KERNEL_COMMIT
      ;;
esac

# using rpi-update relevant to defined kernel version
echo y | CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt SKIP_BACKUP=1 WANT_PI4=1 SKIP_CHECK_PARTITION=1 UPDATE_SELF=0 rpi-update $KERNEL_COMMIT

echo "Getting actual kernel revision with firmware revision backup"
cp /boot/.firmware_revision /boot/.firmware_revision_kernel

echo "Updating bootloader files *.elf *.dat *.bin"
echo y | CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt SKIP_KERNEL=1 WANT_PI4=1 SKIP_CHECK_PARTITION=1 UPDATE_SELF=0 rpi-update $FIRMWARE_COMMIT

if [ -d "/lib/modules/${KERNEL_VERSION}-v8+" ]; then
	echo "Removing v8+ Kernels"
	rm /boot/kernel8.img
	rm -rf "/lib/modules/${KERNEL_VERSION}-v8+"
fi


echo "Blocking unwanted libraspberrypi0, raspberrypi-bootloader, raspberrypi-kernel installs"
# these packages critically update kernel & firmware files and break Volumio
# may be triggered by manual or plugin installs explicitly or through dependencies like chromium, sense-hat, picamera,...
echo "Package: raspberrypi-bootloader
Pin: release *
Pin-Priority: -1

Package: raspberrypi-kernel
Pin: release *
Pin-Priority: -1" > /etc/apt/preferences
apt-mark hold raspberrypi-kernel raspberrypi-bootloader   #libraspberrypi0 depends on raspberrypi-bootloader
apt-mark hold nodejs

echo "Adding PI3 & PiZero W Wireless, PI WIFI Wireless dongle, ralink mt7601u & few others firmware upgraging to Pi Foundations packages"
apt-get install -y --allow-downgrades firmware-atheros/buster-backports firmware-realtek/buster-backports firmware-brcm80211/buster-backports

#echo "Adding raspi-config"
#wget -P /raspi http://archive.raspberrypi.org/debian/pool/main/r/raspi-config/raspi-config_20151019_all.deb
#dpkg -i /raspi/raspi-config_20151019_all.deb
#rm -Rf /raspi

#echo "Installing WiringPi from Raspberrypi.org Repo"
#apt-get -y install wiringpi

#echo "Configuring boot splash"
#apt-get -y install plymouth plymouth-themes
#plymouth-set-default-theme volumio

echo "Removing unneeded binaries"
apt-get -y remove binutils

echo "Writing config.txt file"
echo "initramfs volumio.initrd
gpu_mem=16
max_usb_current=1
# dtparam=audio=on
audio_pwm_mode=2
dtparam=i2c_arm=on
#disable_splash=1
hdmi_force_hotplug=1
# add overlay for mcp23017 GPIO expander
dtoverlay=mcp23017,gpiopin=27,addr=0x25
#20180606-Emre Ozkan-added overlay for applechip
dtoverlay=i2c-rtc,pcf2127
##20180621-Emre Ozkan powerled and activity led turned off
dtparam=act_led_trigger=none
dtparam=act_led_activelow=off
dtparam=pwr_led_trigger=none
dtparam=pwr_led_activelow=off
#### Volumio i2s setting below: do not alter ####
dtoverlay=hifiberry-dacplus
dtoverlay=gpio-ir,gpio_pin=9,gpio_pull=up
" >> /boot/config.txt

echo "Writing cmdline.txt file"
echo "dwc_otg.fiq_enable=1 dwc_otg.fiq_fsm_enable=1 dwc_otg.fiq_fsm_mask=0xF dwc_otg.nak_holdoff=1 console=serial0,115200 kgdboc=serial0,115200 console=tty1 imgpart=/dev/mmcblk0p2 imgfile=/volumio_current.sqsh elevator=noop rootwait bootdelay=5 logo.nologo vt.global_cursor_default=0 loglevel=0 net.ifnames=0" >> /boot/cmdline.txt

echo "adding gpio & spi group and permissions"
groupadd -f --system gpio
groupadd -f --system spi

echo "adding volumio to gpio group and al"
usermod -a -G gpio,i2c,spi,input volumio

echo "Installing raspberrypi-sys-mods System customizations"
apt-get -y install raspberrypi-sys-mods
rm /etc/sudoers.d/010_pi-nopasswd
unlink /etc/systemd/system/multi-user.target.wants/sshswitch.service
rm /lib/systemd/system/sshswitch.service

echo "Exporting /opt/vc/bin variable"
export LD_LIBRARY_PATH=/opt/vc/lib/:LD_LIBRARY_PATH

echo "Adding custom modules"
echo "squashfs" >> /etc/initramfs-tools/modules
echo "overlay" >> /etc/initramfs-tools/modules

echo "Customizing pre and post actions for dtoverlay"

echo "echo 'pre'" > /opt/vc/bin/dtoverlay-pre
chmod a+x /opt/vc/bin/dtoverlay-pre
echo "echo 'post'" > /opt/vc/bin/dtoverlay-post
chmod a+x /opt/vc/bin/dtoverlay-post

echo "DTOverlay utility"

ln -s /opt/vc/lib/libdtovl.so /usr/lib/libdtovl.so
ln -s /opt/vc/bin/dtoverlay /usr/bin/dtoverlay
ln -s /opt/vc/bin/dtoverlay-pre /usr/bin/dtoverlay-pre
ln -s /opt/vc/bin/dtoverlay-post /usr/bin/dtoverlay-post

echo "Setting Vcgencmd"

ln -s /opt/vc/lib/libvchiq_arm.so /usr/lib/libvchiq_arm.so
ln -s /opt/vc/bin/vcgencmd /usr/bin/vcgencmd
ln -s /opt/vc/lib/libvcos.so /usr/lib/libvcos.so

# changing external ethX priority rule for Pi as built-in eth _is_ on USB (smsc95xx or lan78xx drivers)
sed -i 's/KERNEL==\"eth/DRIVERS!=\"smsc95xx\", DRIVERS!=\"lan78xx\", &/' /etc/udev/rules.d/99-Volumio-net.rules

echo "Installing Wireless drivers for 8188eu, 8192eu, 8812au, mt7610, and mt7612. Many thanks MrEngman"
### We cache the drivers archives upon first request on Volumio server, to relieve stress on mr engmans
#MRENGMAN_REPO="http://wifi-drivers.volumio.org/wifi-drivers"
#MRENGMAN_REPO="http://downloads.fars-robotics.net/wifi-drivers"
MRENGMAN_REPO="https://s3.amazonaws.com/axiom-air-install-files/Common"

#mkdir wifi
#cd wifi
#
#for DRIVER in 8188eu 8192eu 8812au mt7610 mt7612
#do
#  echo "WIFI: $DRIVER for armv7"
#  wget $MRENGMAN_REPO/$DRIVER-drivers/$DRIVER-$KERNEL_VERSION-v7-$KERNEL_REV.tar.gz
#  tar xf $DRIVER-$KERNEL_VERSION-v7-$KERNEL_REV.tar.gz
#  sed -i 's/^kernel=.*$/kernel='"$KERNEL_VERSION"'-v7+/' install.sh
#  sh install.sh
#  rm -rf *
#
#  echo "WIFI: $DRIVER for armv6"
#  wget $MRENGMAN_REPO/$DRIVER-drivers/$DRIVER-$KERNEL_VERSION-$KERNEL_REV.tar.gz
#  tar xf $DRIVER-$KERNEL_VERSION-$KERNEL_REV.tar.gz
#  sed -i 's/^kernel=.*$/kernel='"$KERNEL_VERSION"'+/' install.sh
#  sh install.sh
#  rm -rf *
#done
#
#cd ..
#rm -rf wifi

#On The Fly Patch
if [ "$PATCH" = "volumio" ]; then
echo "No Patch To Apply"
else
echo "Applying Patch ${PATCH}"
PATCHPATH=/${PATCH}
cd $PATCHPATH
#Check the existence of patch script
if [ -f "patch.sh" ]; then
sh patch.sh
else
echo "Cannot Find Patch File, aborting"
fi
if [ -f "install.sh" ]; then
sh install.sh
fi
cd /
rm -rf ${PATCH}
fi
rm /patch

echo "Installing winbind here, since it freezes networking"
apt-get install -y winbind libnss-winbind

echo "Finalising drivers installation with depmod on $KERNEL_VERSION+ and $KERNEL_VERSION-v7+"
depmod $KERNEL_VERSION+
depmod $KERNEL_VERSION-v7+
depmod $KERNEL_VERSION-v7l+

echo "Cleaning APT Cache and remove policy file"
rm -f /var/lib/apt/lists/*archive*
apt-get clean
rm /usr/sbin/policy-rc.d

#First Boot operations
echo "Signalling the init script to re-size the volumio data partition"
touch /boot/resize-volumio-datapart


echo "Creating initramfs"
/usr/local/sbin/mkinitramfs-custom.sh -o /tmp/initramfs-tmp
