#!/bin/bash -x

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser.
  exit 1
fi

cd /etc/rc.d/init.d/
curl -XGET -o iptables https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/firewall-service.sh  > /dev/null
chmod +x iptables
chkconfig docker off
chkconfig --add iptables
chkconfig --level 2345 iptables on
service iptables start