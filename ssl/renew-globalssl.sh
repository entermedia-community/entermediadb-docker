#!/bin/bash -x

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser.
  exit 1
fi

LEDIR="/etc/letsencrypt/live/global.unitednations.entermediadb.net"
SSLDIR="/home/entermedia/sslcerts"


if [ ! -d "$SSLDIR" ]; then
  mkdir $SSLDIR
fi

sudo /home/entermedia/letsencrypt/letsencrypt-auto renew
sudo cp $LEDIR/fullchain.pem $SSLDIR && sudo chown entermedia. $SSLDIR/fullchain.pem
sudo cp $LEDIR/privkey.pem $SSLDIR && sudo chown entermedia. $SSLDIR/privkey.pem
