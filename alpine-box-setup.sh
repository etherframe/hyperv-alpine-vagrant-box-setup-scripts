#!/bin/sh

apk add --no-cache --upgrade doas openssl hvtools cifs-utils

DOAS_CONF="/etc/ssh/sshd_config"
echo "permit nopass root" >> "$DOAS_CONF"

adduser -D vagrant
echo "vagrant:vagrant" | chpasswd
echo "permit nopass vagrant as root" >> "$DOAS_CONF"

doas -u vagrant mkdir -m0700 -p /home/vagrant/.ssh
doas -u vagrant wget -O /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
chmod 0600 /home/vagrant/.ssh/authorized_keys

echo "UseDNS no" >> /etc/ssh/sshd_config

rc-update add hv_fcopy_daemon
rc-update add hv_kvp_daemon
rc-update add hv_vss_daemon

apk del openssl

echo -n "Delete script (y/n)?"
read DELETE_SCRIPT
if [ "$DELETE_SCRIPT" != "${DELETE_SCRIPT#[Yy]}" ] ;then
	rm "$0"
fi

find / -name .ash_history -delete
