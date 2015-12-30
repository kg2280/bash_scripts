cat <<EOT> ~/prep.sh

#!/bin/bash


. ./vars

PACKAGE_TO_INSTALL="puppet screen"

if [ ! -e p1.done ]
then

  echo $HOSTNAME > /etc/hostname
  cat << EOF > /etc/network/interfaces
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
allow-hotplug eth0
iface eth0 inet static
	address $IP1
	netmask $NETMASK1
	gateway $GATEWAY

EOF

  ## Check if the secondary IP is set
  if [ -n "$IP2" ] && [ -n "$NETMASK2" ]
  then
  cat << EOF >> /etc/network/interfaces
# The secondary network interface
auto eth1
allow-hotplug eth1
iface eth1 inet static
        address $IP2
        netmask $NETMASK2

EOF
  fi

  ## /etc/hosts
  cat << EOF > /etc/hosts
127.0.0.1 localhost
$IP1	$HOSTNAME.$DOMAIN $HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

  ## /etc/apt/sources.list
  cat << EOF > /etc/apt/sources.list
deb http://debian.mirror.netelligent.ca/debian/ jessie main contrib non-free
deb-src http://debian.mirror.netelligent.ca/debian/ jessie main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free

deb http://debian.mirror.netelligent.ca/debian/ jessie-updates main contrib non-free
deb-src http://debian.mirror.netelligent.ca/debian/ jessie-updates main contrib non-free
EOF

  cat << EOF > /etc/resolv.conf
search $DOMAIN
domain $DOMAIN
nameserver 8.8.8.8
nameserver 4.2.2.2
EOF

  apt-get update
  apt-get install -y $PACKAGE_TO_INSTALL

  cat << EOF > /etc/puppetlabs/puppet/puppet.conf
[main]
    vardir = /var/lib/puppet
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = $vardir/ssl
    factpath=$vardir/lib/facter

[agent]
    server = puppet.modulis.ca
    environment       = $PUPPET_ENV
EOF

  systemctl enable puppet
  systemctl start puppet

  touch p1.done
  reboot

fi
EOT
sh ./prep.sh

