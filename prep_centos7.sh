cat <<EOT> ~/prep.sh
#!/bin/bash

. ./vars

export PACKAGE_TO_INSTALL="nano ca-certificates curl wget man ntp ruby"

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
  cat << EOF > /etc/sysconfig/network-scripts/ifcfg-`ifconfig | grep flags | grep -v lo | cut -f1 -d":"`
TYPE=Ethernet
BOOTPROTO=none
IPV6INIT=yes
NAME=`ifconfig | grep flags | grep -v lo | cut -f1 -d":"`
DEVICE=`ifconfig | grep flags | grep -v lo | cut -f1 -d":"`
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

## Update & Puppet
  cat << EOF > /etc/yum.repos.d/modulis.repo
[modulisrepo]
name=ModulisCentOS Repo
baseurl=http://rpm.modulis.ca/CentOS/\$releasever/\$basearch/
gpgcheck=0
priority=1
EOF

  yum update -y
  yum install $PACKAGE_TO_INSTALL -y
  ntpdate 0.ca.pool.ntp.org
  gem install -v 3.8.4 puppet
  mkdir /etc/puppet/

  cat << EOF > /etc/puppet/puppet.conf
[main]
    vardir = /var/lib/puppet
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = $vardir/ssl
    factpath=$vardir/lib/facter

[agent]
    server = puppet.modulis.ca
EOF

## Starting the service
puppet resource service <NAME> ensure=running enable=true
## Or do a cron job
puppet resource cron puppet-agent ensure=present user=root minute=30 command='/usr/bin/puppet agent --onetime --no-daemonize --splay'
  systemctl enable puppet
  systemctl start puppet

  touch p1.done
  reboot

fi
EOT
sh ./prep.sh

