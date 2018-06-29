#!/bin/bash -x

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser.
  exit 1
fi

GLOBALDIR="/home/entermedia/globalssl"
CERTSDIR="$GLOBALDIR/sslcerts"

sudo cp $CERTSDIR/*.pem /etc/letsencrypt/live/global.unitednations.entermediadb.net/
