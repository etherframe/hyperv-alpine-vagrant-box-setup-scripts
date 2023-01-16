#!/bin/sh

rc-update add sshd default

cat > /etc/network/interfaces <<- EOF
	iface lo inet loopback
	iface eth0 inet dhcp
EOF

ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0

rc-update add net.eth0 default
rc-update add net.lo boot

mkdir -p /root/.ssh
chmod 700 /root/.ssh

cat > /bin/do-init <<- EOF
	#!/bin/sh
	wget -T 5 http://169.254.169.254/metadata/v1/hostname -q -O /etc/hostname
	hostname -F /etc/hostname
	wget -T 5 http://169.254.169.254/metadata/v1/public-keys -O /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
	rc-update del do-init default
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
