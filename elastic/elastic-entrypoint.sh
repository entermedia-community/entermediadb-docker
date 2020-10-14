#!/bin/bash

if [[ ! `id -u` -eq 0 ]]; then
	echo You must run this script as a superuser.
	exit 1
fi

if [[ ! `id -u entermedia 2> /dev/null` ]]; then
	groupadd -g $GROUPID entermedia
	useradd -ms /bin/bash entermedia -g entermedia -u $USERID
fi

# SIGTERM-handler
term_handler() {
    pid=$(cat /tmp/elasticsearch.pid)
if [[ ! -z $pid ]]; then
  if [ $pid -ne 0 ]; then
	echo "Deployment shutdown start"
    kill -SIGTERM "$pid"
	while [ -e /proc/$pid ]
	do
		printf .
		sleep 1
	done
  fi
fi
  exit 143; # 128 + 15 -- SIGTERM
}


trap 'kill ${!}; term_handler' SIGTERM

# debug

CUSTOM_NODENUMBER=$NODENUMBER

if [ "$NODENUMBER" -ge 100 -a "$NODENUMBER" -le 199 ]; then
	CUSTOM_NODENUMBER=$((NODENUMBER - 90))
fi

if [ ! -f /etc/elasticsearch/elasticsearch.yml ]; then
	sed "s|CLUSTER_NAME|$CLUSTER_NAME|g;s|UNICAST_HOSTS|$UNICAST_HOSTS|g;s|PUBLISH_HOST|$PUBLISH_HOST|g;s|NODE_NUMBER|$CUSTOM_NODENUMBER|g;s|NODE_NAME|$NODENAME|g;" < /usr/share/elasticsearch/config/elasticsearch.yml.template > /usr/share/elasticsearch/config/elasticsearch.yml
    sudo chown entermedia:entermedia -R /usr/share/elasticsearch
    cp /usr/share/elasticsearch/config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
    cp /usr/share/elasticsearch/config/logging.yml /etc/elasticsearch/
    sudo chown entermedia:entermedia -R /etc/elasticsearch
fi

/usr/share/elasticsearch/bin/elasticsearch-systemd-pre-exec

# Run as entermedia search from the host OS
sudo -u entermedia sh -c "/usr/share/elasticsearch/bin/elasticsearch -Des.network.host=0.0.0.0 \
                                           -Des.pidfile=/tmp/elasticsearch.pid \
                                           -Des.default.path.home=/usr/share/elasticsearch \
                                           -Des.default.path.logs=/var/log/elasticsearch \
                                           -Des.default.path.data=/var/lib/elasticsearch \
                                           -Des.default.path.conf=/etc/elasticsearch" &

while true
do
  wait ${!}
done
