#!/bin/bash -x

if [ "$#" -ne 3 ]; then
    echo "usage: server instancename instancenode"
    exit 1
fi

SERVER=$1
INSTANCE=$2
NODE=$3

#Stop instance
DOCKER="sudo docker rm -f $INSTANCE$NODE"
ssh -tt $SERVER "$DOCKER"

#Remove from NGINX
NGINX="sudo mv $CONFIGFILE $CONFIGFILE_deleted && sudo nginx -s reload"
ssh -tt $SERVER "$NGINX"

#Delete the EM files under /media/emsite/instance
ERASE="sudo mv /media/emsites/$INSTANCE /media/emsites/${INSTANCE}_disabled"
ssh -tt $SERVER "$ERASE"

ERASE="sudo mv /media/emsites/${INSTANCE}_disabled /media/emsites/${INSTANCE}_deleted"
ssh -tt $SERVER "$ERASE"
