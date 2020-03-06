#!/bin/bash -x

if [ "$#" -ne 3 ]; then
    echo "usage: server url nodenumber"
    exit 1
fi

SERVER=$1
URL=$2
NODE=$3
CONFIGFILE="/etc/nginx/conf.d/trial-$URL.conf"

#Shut down instance and clean NGINX config
#SHUTDOWN="sudo docker stop $URL$NODE && sudo docker rm $URL$NODE"
SHUTDOWN="sudo docker stop $URL$NODE"
NGINX="sudo mv $CONFIGFILE $CONFIGFILE_disabled && sudo nginx -s reload"

ssh -tt $SERVER "$SHUTDOWN && $NGINX"
