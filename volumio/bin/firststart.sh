#!/bin/bash

echo "Volumio first start configuration script"

echo "configuring unconfigured packages"
dpkg --configure --pending

echo "Creating /var/log/samba folder"
mkdir /var/log/samba

echo "Removing default SSH host keys"
# These should be created on first boot to ensure they are unique on each system
rm -v /etc/ssh/ssh_host_*

echo "Generating SSH host keys"
dpkg-reconfigure openssh-server

#Generate hostname from MAC address
HOST_PREFIX=${HOST_PREFIX:-"AxiomAir"}
NET_DEVICE=${NET_DEVICE:="eth0"}
LAST_MAC6=$(sed -rn "s/^.*([0-9A-F:]{8})$/\1/gi;s/://gp" /sys/class/net/${NET_DEVICE}/address)
NEW_HOSTNAME=${HOST_PREFIX}-${LAST_MAC6:-000000}

echo $NEW_HOSTNAME > /etc/hostname
echo "127.0.0.1 localhost $NEW_HOSTNAME" > /etc/hosts
/bin/hostname -F /etc/hostname


echo "Disabling firststart service"
systemctl disable firststart.service

echo "Finalizing"
sync
