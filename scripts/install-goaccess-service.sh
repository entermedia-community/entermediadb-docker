#!/bin/bash -x

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser.
  exit 1
fi

cd /etc/rc.d/init.d/
curl -XGET -o generate_netreport https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/scripts/goaccess-realtime-reports-service.sh  > /dev/null
chmod +x generate_netreport
chkconfig --add generate_netreport
chkconfig --level 2345 generate_netreport on
service generate_netreport start

