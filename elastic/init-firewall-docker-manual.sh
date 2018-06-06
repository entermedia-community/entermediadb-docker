#!/bin/bash -x

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser
  exit 1
fi

if [ -z "$1" ]
  then
    echo "Missing local instance node"
  exit 1
fi
if [ -z "$2" ]
  then
    echo "Missing IP"
  exit 1
fi

NODE=$1
IP=$2

wget -O - https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/elastic/firewall-docker-manual.sh > firewall-docker-manual.sh
chmod +x firewall-docker-manual.sh

FILE='{
    "iptables": false
}'

# Forbid Docker to modify the iptables
echo $FILE > /etc/docker/daemon.json

# Flush iptables, set custom rules and restart docker service
./firewall-docker-manual.sh $NODE $IP
