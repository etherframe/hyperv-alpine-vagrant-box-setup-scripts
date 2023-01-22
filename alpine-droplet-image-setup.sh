#!/bin/sh

METADATA_URL="http://169.254.169.254/metadata/v1"

rc-update add sshd default

cat > /etc/network/interfaces <<- EOF
	iface lo inet loopback
	iface eth0 inet dhcp
EOF

ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0

rc-update add net.eth0 default
rc-update add net.lo boot

mkdir -m0700 -p /root/.ssh

cat > /bin/do-init <<- EOF
	#!/bin/sh

	# Get hostname
	wget -O /etc/hostname $METADATA_URL/hostname
	hostname -F /etc/hostname

	# Get SSH key
	wget -O /root/.ssh/authorized_keys $METADATA_URL/public-keys
	chmod 0600 /root/.ssh/authorized_keys

	# Clean up init
	rc-update del do-init default
	rm "\$0"

	exit 0
EOF

cat > /etc/init.d/do-init <<- EOF
	#!/sbin/openrc-run

	depend() {
	    need net.eth0
	}

	command="/bin/do-init"
	command_args=""
	pidfile="/tmp/do-init.pid"
EOF

chmod +x /etc/init.d/do-init
chmod +x /bin/do-init

rc-update add do-init default

echo -n "Delete script (y/n)?"
read DELETE_SCRIPT
if [ "$DELETE_SCRIPT" != "${DELETE_SCRIPT#[Yy]}" ] ;then
	rm "$0"
fi

find / -name .ash_history -delete
