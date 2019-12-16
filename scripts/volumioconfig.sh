#!/bin/bash

NODE_VERSION=8.11.1

# This script will be run in chroot under qemu.

echo "Prevent services starting during install, running under chroot"
echo "(avoids unnecessary errors)"
cat > /usr/sbin/policy-rc.d << EOF
exit 101
EOF
chmod +x /usr/sbin/policy-rc.d

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C
/var/lib/dpkg/info/dash.preinst install
dpkg --configure -a

# Reduce locales to just one beyond C.UTF-8
echo "Existing locales:"
locale -a
echo "Generating required locales:"
[ -f /etc/locale.gen ] || touch -m /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "Removing unused locales"
echo "en_US.UTF-8" >> /etc/locale.nopurge
# To remove existing locale data we must turn off the dpkg hook
sed -i -e 's/^USE_DPKG/#USE_DPKG/' /etc/locale.nopurge
# Ensure that the package knows it has been configured
sed -i -e 's/^NEEDSCONFIGFIRST/#NEEDSCONFIGFIRST/' /etc/locale.nopurge
dpkg-reconfigure localepurge -f noninteractive
localepurge
# Turn dpkg feature back on, it will handle further locale-cleaning
sed -i -e 's/^#USE_DPKG/USE_DPKG/' /etc/locale.nopurge
dpkg-reconfigure localepurge -f noninteractive
echo "Final locale list"
locale -a
echo ""

#Adding Main user Volumio
echo "Adding Volumio User"
groupadd volumio
useradd -c volumio -d /home/volumio -m -g volumio -G adm,dialout,cdrom,floppy,audio,dip,video,plugdev,netdev -s /bin/bash -p '$6$tRtTtICB$Ki6z.DGyFRopSDJmLUcf3o2P2K8vr5QxRx5yk3lorDrWUhH64GKotIeYSNKefcniSVNcGHlFxZOqLM6xiDa.M.' volumio

#Setting Root Password
echo 'root:$1$JVNbxLRo$pNn5AmZxwRtWZ.xF.8xUq/' | chpasswd -e

#Global BashRC Aliases"
echo 'Setting BashRC for custom system calls'
echo ' ## System Commands ##
alias reboot="sudo /sbin/reboot"
alias poweroff="sudo /sbin/poweroff"
alias halt="sudo /sbin/halt"
alias shutdown="sudo /sbin/shutdown"
alias apt-get="sudo /usr/bin/apt-get"
alias systemctl="/bin/systemctl"
alias iwconfig="iwconfig wlan0"
## Utilities thanks to http://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html ##
## Colorize the ls output ##
alias ls="ls --color=auto"
## Use a long listing format ##
alias ll="ls -la"
## Show hidden files ##
alias l.="ls -d .* --color=auto"
## get rid of command not found ##
alias cd..="cd .."
## a quick way to get out of current directory ##
alias ..="cd .."
alias ...="cd ../../../"
alias ....="cd ../../../../"
alias .....="cd ../../../../"
alias .4="cd ../../../../"
alias .5="cd ../../../../.."
# install with apt-get
alias updatey="sudo apt-get --yes"
## Read Like humans ##
alias df="df -H"
alias du="du -ch"
alias snapclient="/usr/sbin/snapclient"
alias snapserver="/usr/sbin/snapserver"
alias mount="sudo /bin/mount"
alias systemctl="sudo /bin/systemctl"
alias killall="sudo /usr/bin/killall"
alias service="sudo /usr/sbin/service"
alias ifconfig="sudo /sbin/ifconfig"
' >> /etc/bash.bashrc

#Sudoers Nopasswd
SUDOERS_FILE="/etc/sudoers.d/volumio-user"
echo 'Adding Safe Sudoers NoPassw permissions'
cat > ${SUDOERS_FILE} << EOF
# Add permissions for volumio user
volumio ALL=(ALL) ALL
volumio ALL=(ALL) NOPASSWD: /sbin/poweroff,/sbin/shutdown,/sbin/reboot,/sbin/halt,/bin/systemctl,/usr/bin/apt-get,/usr/sbin/update-rc.d,/usr/bin/gpio,/bin/mount,/bin/umount,/sbin/iwconfig,/sbin/iwlist,/sbin/ifconfig,/usr/bin/killall,/bin/ip,/usr/sbin/service,/etc/init.d/netplug,/bin/journalctl,/bin/chmod,/sbin/ethtool,/usr/sbin/alsactl,/bin/tar,/usr/bin/dtoverlay,/sbin/dhclient,/usr/sbin/i2cdetect,/sbin/dhcpcd,/usr/bin/alsactl,/bin/mv,/sbin/iw,/bin/hostname,/sbin/modprobe,/sbin/iwgetid,/bin/ln,/usr/bin/unlink,/bin/dd,/usr/bin/dcfldd,/opt/vc/bin/vcgencmd
volumio ALL=(ALL) NOPASSWD: /bin/sh /volumio/app/plugins/system_controller/volumio_command_line_client/commands/kernelsource.sh, /bin/sh /volumio/app/plugins/system_controller/volumio_command_line_client/commands/pull.sh, /usr/local/bin/axiom-updater.sh, /usr/local/vpnclient/vpnclient, /usr/local/vpnclient/vpncmd

EOF
chmod 0440 ${SUDOERS_FILE}

echo BryFi-default > /etc/hostname
chmod 777 /etc/hostname
chmod 777 /etc/hosts

echo "nameserver 8.8.8.8" > /etc/resolv.conf

################
#Volumio System#---------------------------------------------------
################
echo "Arm Environment detected"
echo ' Adding Raspbian Repo Key'
wget https://archive.raspbian.org/raspbian.public.key -O - | sudo apt-key add -

# Symlinking to legacy paths
ln -s /usr/bin/node /usr/local/bin/node
ln -s /usr/bin/npm /usr/local/bin/npm

#  echo "Installing Volumio Modules"
#  cd /volumio
#  wget http://repo.volumio.org/Volumio2/node_modules_arm-${NODE_VERSION}.tar.gz
#  tar xf node_modules_arm-${NODE_VERSION}.tar.gz
#  rm node_modules_arm-${NODE_VERSION}.tar.gz

echo "Setting proper ownership"
chown -R volumio:volumio /volumio

echo "Creating Data Path"
mkdir /data
chown -R volumio:volumio /data

echo "Creating ImgPart Path"
mkdir /imgpart
chown -R volumio:volumio /imgpart

echo "Changing os-release permissions"
chown volumio:volumio /etc/os-release
chmod 777 /etc/os-release

echo "Installing Custom Packages"
cd /

ARCH=$(cat /etc/os-release | grep ^VOLUMIO_ARCH | tr -d 'VOLUMIO_ARCH="')
echo $ARCH
echo "Installing custom MPD depending on system architecture"


echo "Installing MPD for armv7"
# First we manually install a newer alsa-lib to achieve Direct DSD support

   echo "Installing MPD 20.6 with Direct DSD Support"
   wget https://github.com/ColquhounAudio/mpd-0.20.20-volumio/releases/download/0.20.20-1/mpd_0.20.20-1-volumio_armhf.deb
   dpkg -i mpd_0.20.20-1-volumio_armhf.deb
   rm mpd_0.20.20-1-volumio_armhf.deb


echo "Installing Snapcast"
   wget https://s3.amazonaws.com/axiom-air-install-files/AxiomAirV2/v1.0/snapserver_0.15.0_armhf.deb
   wget https://s3.amazonaws.com/axiom-air-install-files/AxiomAirV2/v1.0/snapclient_0.15.0_armhf.deb

   dpkg -i snapclient_0.15.0_armhf.deb
   rm snapclient_0.15.0_armhf.deb
 
   dpkg -i snapserver_0.15.0_armhf.deb
   rm snapserver_0.15.0_armhf.deb

   ln -s /usr/bin/snapserver /usr/sbin/snapserver
   ln -s /usr/bin/snapclient /usr/sbin/snapclient

   chmod a+x /usr/bin/snapserver
   chmod a+x /usr/bin/snapclient

   chmod a+x /usr/sbin/snapserver
   chmod a+x /usr/sbin/snapclient

   systemctl disable snapserver
   systemctl disable snapclient

#Remove autostart of upmpdcli
update-rc.d upmpdcli remove


#echo "Installing Shairport-Sync"
#wget http://repo.volumio.org/Volumio2/Binaries/shairport-sync-metadata-reader-arm.tar.gz
#tar xf shairport-sync-metadata-reader-arm.tar.gz
#rm /shairport-sync-metadata-reader-arm.tar.gz

#echo "Installing Shairport-Sync Metadata Reader"
#wget http://repo.volumio.org/Volumio2/Binaries/shairport-sync-3.0.2-arm.tar.gz
#tar xf shairport-sync-3.0.2-arm.tar.gz
#rm /shairport-sync-3.0.2-arm.tar.gz

#  echo "Adding volumio-remote-updater for armv7"
#  wget http://repo.volumio.org/Volumio2/Binaries/arm/volumio-remote-updater_1.3-armv7.deb
#  dpkg -i volumio-remote-updater_1.3-armv7.deb
#  rm volumio-remote-updater_1.3-armv7.deb


echo "Volumio Init Updater"
#  wget http://repo.volumio.org/Volumio2/Binaries/arm/volumio-init-updater-v2 -O /usr/local/sbin/volumio-init-updater
wget https://s3.amazonaws.com/axiom-air-install-files/AxiomAirV2/v1.0/volumio-init-updater-v2 -O /usr/local/sbin/volumio-init-updater
chmod a+x /usr/local/sbin/volumio-init-updater

#  echo "Zsync"
#  rm /usr/bin/zsync
#  wget http://repo.volumio.org/Volumio2/Binaries/arm/zsync -P /usr/bin/
#  chmod a+x /usr/bin/zsync
#
#  echo "Adding special version for edimax dongle"
#  wget http://repo.volumio.org/Volumio2/Binaries/arm/hostapd-edimax -P /usr/sbin/
#  chmod a+x /usr/sbin/hostapd-edimax
#
echo "interface=wlan0
ssid=BryFi
channel=4
driver=rtl871xdrv
hw_mode=g
auth_algs=1
#wpa=2
#wpa_key_mgmt=WPA-PSK
#rsn_pairwise=CCMP
#wpa_passphrase=volumio2" >> /etc/hostapd/hostapd-edimax.conf
chmod -R 777 /etc/hostapd-edimax.conf

echo "Cleanup"
apt-get clean
rm -rf tmp/*

echo "Creating Volumio Folder Structure"
# Media Mount Folders
mkdir /mnt/NAS
mkdir /media
ln -s /media /mnt/USB

#Internal Storage Folder
mkdir /data/INTERNAL
ln -s /data/INTERNAL /mnt/INTERNAL

#UPNP Folder
mkdir /mnt/UPNP

#Permissions
chmod -R 777 /mnt
chmod -R 777 /media
chmod -R 777 /data/INTERNAL

# Symlinking Mount Folders to Mpd's Folder
ln -s /mnt/NAS /var/lib/mpd/music
ln -s /mnt/USB /var/lib/mpd/music
ln -s /mnt/INTERNAL /var/lib/mpd/music

echo "Prepping MPD environment"
touch /var/lib/mpd/tag_cache
chmod 777 /var/lib/mpd/tag_cache
chmod 777 /var/lib/mpd/playlists

echo "Setting mpdignore file"
echo "@Recycle
#recycle
$*
System Volume Information
$RECYCLE.BIN
RECYCLER
" > /var/lib/mpd/music/.mpdignore

echo "Setting mpc to bind to unix socket"
export MPD_HOST=/run/mpd/socket
chmod g+rwx /run/mpd

echo "Setting Permissions for /etc/modules"
chmod 777 /etc/modules



echo "Netplug service"
systemctl enable netplug

echo "SnapService"
ln -s /lib/systemd/system/snapservice.service /etc/systemd/system/multi-user.target.wants/snapservice.service

echo "Quality Check"
ln -s /lib/systemd/system/qualitycheck.service /etc/systemd/system/multi-user.target.wants/qualitycheck.service

echo "Adding Volumio Parent Service to Startup"
#systemctl enable volumio.service
ln -s /lib/systemd/system/volumio.service /etc/systemd/system/multi-user.target.wants/volumio.service

echo "Adding Udisks-glue service to Startup"
ln -s /lib/systemd/system/udisks-glue.service /etc/systemd/system/multi-user.target.wants/udisks-glue.service

echo "Adding First start script"
ln -s /lib/systemd/system/firststart.service /etc/systemd/system/multi-user.target.wants/firststart.service

echo "Adding Dynamic Swap Service"
ln -s /lib/systemd/system/dynamicswap.service /etc/systemd/system/multi-user.target.wants/dynamicswap.service

echo "Adding Iptables Service"
ln -s /lib/systemd/system/iptables.service /etc/systemd/system/multi-user.target.wants/iptables.service

echo "Disabling SSH by default"
systemctl disable ssh.service
echo "Enable AirplayD by default"
systemctl enable airplay.service
systemctl disable airplay2.service

echo "Enable Axiom IO services"
systemctl enable axiom_hwconfig.service
systemctl enable axiom_ledinit.service
systemctl enable axiompoweroff.service
systemctl enable update_service.service

echo "Enable Volumio SSH enabler"
ln -s /lib/systemd/system/volumiossh.service /etc/systemd/system/multi-user.target.wants/volumiossh.service

echo "Setting Mpd to SystemD instead of Init"
update-rc.d mpd remove
systemctl enable mpd.service

echo "Disable hotspot services at boot"
systemctl disable hotspot.service
systemctl disable dnsmasq.service

echo "Enable wac services at boot"
systemctl disable wac.service

echo "Preventing upmpdcli at boot"
systemctl disable upmpdcli.service

echo "Bluetooth enabled"
systemctl enable bluetooth
systemctl enable bluealsa
systemctl enable bt-agent
systemctl enable a2dp-playback

echo "Lirc Devinput enabled"
systemctl enable lircd-devinput
systemctl enable irexec-devinput

echo "Roon enabled"
systemctl enable roonbridge

echo "Preventing un-needed dhcp servers to start automatically"
systemctl disable isc-dhcp-server.service
#systemctl disable dhcpd.service

echo "Linking Volumio Command Line Client"
ln -s /volumio/app/plugins/system_controller/volumio_command_line_client/volumio.sh /usr/local/bin/volumio
chmod a+x /usr/local/bin/volumio

echo "Initialize the lease file for dhcpd"
touch /var/lib/dhcp/dhcpd.leases

#####################
#Audio Optimizations#-----------------------------------------
#####################

echo "Adding Users to Audio Group"
usermod -a -G audio volumio
usermod -a -G audio mpd

echo "Setting RT Priority to Audio Group"
echo '@audio - rtprio 99
@audio - memlock unlimited' >> /etc/security/limits.conf

echo "Alsa tuning"


echo "Creating Alsa state file"
touch /var/lib/alsa/asound.state
echo "state.sndrpihifiberry {
	control.1 {
		iface MIXER
		name Digital
		value.0 50
		value.1 50
		comment {
		access 'read write user'
		type INTEGER
		count 2
		range '0 - 99'
		tlv '0000000100000008ffffe4a800000046'
		dbmin -7000
		dbmax -70
		dbvalue.0 -3500
		dbvalue.1 -3500
		}
	}
}" > /var/lib/alsa/asound.state
chmod 777 /var/lib/alsa/asound.state

echo "Fixing UPNP L16 Playback issue"
grep -v '^@ENABLEL16' /usr/share/upmpdcli/protocolinfo.txt > /usr/share/upmpdcli/protocolinfo.txtrepl && mv /usr/share/upmpdcli/protocolinfo.txtrepl /usr/share/upmpdcli/protocolinfo.txt

#####################
#Network Settings and Optimizations#-----------------------------------------
#####################


echo "Tuning LAN"
echo 'fs.inotify.max_user_watches = 524288' >> /etc/sysctl.conf

echo "Disabling IPV6"
echo "#disable ipv6" | tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" | tee -a /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | tee -a /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | tee -a /etc/sysctl.conf

#echo "Wireless"
#ln -s /lib/systemd/system/wireless.service /etc/systemd/system/multi-user.target.wants/wireless.service

echo "Configuring hostapd"
echo "interface=wlan0
ssid=BryFi
channel=4
driver=nl80211
hw_mode=g
auth_algs=1
#wpa=2
#wpa_key_mgmt=WPA-PSK
#rsn_pairwise=CCMP
#wpa_passphrase=volumio2
" >> /etc/hostapd/hostapd.conf

echo "Hostapd conf files"
cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.tmpl
chmod -R 777 /etc/hostapd

echo "Empty resolv.conf.head for custom DNS settings"
touch /etc/resolv.conf.head

echo "Setting fallback DNS with OpenDNS nameservers"
echo "# OpenDNS nameservers
nameserver 208.67.222.222
nameserver 208.67.220.220" > /etc/resolv.conf.tail.tmpl
chmod 666 /etc/resolv.conf.*
ln -s /etc/resolv.conf.tail.tmpl /etc/resolv.conf.tail

echo "Removing Avahi Service for UDISK-SSH"
rm /etc/avahi/services/udisks.service

#####################
#CPU  Optimizations#-----------------------------------------
#####################

echo "Setting CPU governor to performance"
echo 'GOVERNOR="performance"' > /etc/default/cpufrequtils

