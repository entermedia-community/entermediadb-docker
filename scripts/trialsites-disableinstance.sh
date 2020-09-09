#!/bin/bash -x

if [ "$#" -ne 3 ]; then
    echo "usage: server instancename instancenode"
    exit 1
fi

SERVER=$1
INSTANCE=$2
NODE=$3
CONFIGFILE="/etc/nginx/conf.d/trial-$INSTANCE.conf"

#Stop instance
DOCKER="sudo docker stop $INSTANCE$NODE"
ssh -tt $SERVER "$DOCKER"

#Remove from NGINX
NGINX="sudo mv $CONFIGFILE $CONFIGFILE_disabled && sudo nginx -s reload"
ssh -tt $SERVER "$NGINX"

#Disabled
ERASE="sudo mv /media/emsites/$INSTANCE /media/emsites/${INSTANCE}_disabled"
ssh -tt $SERVER "$ERASE"
