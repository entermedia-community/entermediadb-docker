#!/bin/bash -x

if [ "$#" -ne 2 ]; then
    echo "usage: server url"
    exit 1
fi

SERVER=$1
URL=$2

#Delete the EM files under /media/emsite/instance
ERASE="sudo rm -rf /media/emsites/$URL"

ssh -tt $SERVER "$ERASE"
