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

#Delete the EM files under /media/emsite/instance
ERASE="sudo mv /media/emsites/$INSTANCE /media/emsites/$INSTANCE_old"

ssh -tt $SERVER "$DOCKER && $ERASE"
