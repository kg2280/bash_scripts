cat <<EOT> ~/prep.sh
#!/bin/bash

. ./vars


if [ ! -e p1.done ]
then
  #### /etc/sysconfig/network ####
  cat << EOF > /etc/sysconfig/network
NETWORKING=yes
NETWORKING_IPV6=no
HOSTNAME=$HOSTNAME.$DOMAIN
GATEWAY=$GATEWAY
EOF

  #### /etc/sysconfig/network-scripts/ifcfg-int ####
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-`ifconfig | grep -v "^ " | grep -v lo | awk '{print $1}' | tr -d "\n" | tr -d ":"`
TYPE=Ethernet
BOOTPROTO=none
IPV6INIT=yes
NAME=`ifconfig | grep -v "^ " | grep -v lo | awk '{print $1}' | tr -d "\n" | tr -d ":"`
DEVICE=`ifconfig | grep -v "^ " | grep -v lo | awk '{print $1}' | tr -d "\n" | tr -d ":"`
ONBOOT=yes
IPADDR=$IP1
NETMASK=$NETMASK1
EOF

  #### /etc/hosts ####
  cat << EOF > /etc/hosts
127.0.0.1 localhost
$IP1	$HOSTNAME.$DOMAIN $HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF


  #### resolv.conf ####
  cat << EOF > /etc/resolv.conf
search $DOMAIN
domain $DOMAIN
nameserver 8.8.8.8
nameserver 4.2.2.2
EOF

  #### update ####
  yum update -y

  #### Puppet config ####
#  rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
#  yum install -y $PACKAGE_TO_INSTALL
#  cat << EOF > /etc/puppetlabs/puppet/puppet.conf
#[main]
#    vardir = /var/lib/puppet
#    logdir = /var/log/puppet
#    rundir = /var/run/puppet
#    ssldir = $vardir/ssl
#    factpath=$vardir/lib/facter
#
#[agent]
#    server = puppet.modulis.ca
#    environment       = $PUPPET_ENV
#EOF
#
#  systemctl enable puppet
#  systemctl start puppet

  touch p1.done
  reboot

fi
EOT
sh ./prep.sh

